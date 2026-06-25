import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  late RtcEngine _engine;
  bool _initialized = false;

  String get _appId => dotenv.env['AGORA_APP_ID'] ?? '';

  Future<void> init() async {
    if (_initialized) return;

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: _appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final camera = await Permission.camera.request();
    final microphone = await Permission.microphone.request();
    return camera.isGranted && microphone.isGranted;
  }

  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
    bool isHost = false,
  }) async {
    await _engine.enableVideo();
    await _engine.setClientRole(
      role: isHost ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
    );

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  Future<void> toggleMute(bool muted) async {
    await _engine.muteLocalAudioStream(muted);
  }

  Future<void> toggleVideo(bool off) async {
    await _engine.muteLocalVideoStream(off);
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }

  void onRemoteVideoJoined(void Function(int uid) onJoined) {
    _engine.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (connection, remoteUid, elapsed) {
        onJoined(remoteUid);
      },
    ));
  }

  void onRemoteVideoLeft(void Function(int uid) onLeft) {
    _engine.registerEventHandler(RtcEngineEventHandler(
      onUserOffline: (connection, remoteUid, reason) {
        onLeft(remoteUid);
      },
    ));
  }

  RtcEngine get engine => _engine;

  Future<void> dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
    _initialized = false;
  }
}
