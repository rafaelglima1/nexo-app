import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../core/api/api_client.dart';
import 'data/video_service.dart';
import 'widgets/video_participant_tile.dart';
import 'widgets/room_chat_panel.dart';
import 'widgets/guided_questions_bar.dart';

class VideoRoomScreen extends StatefulWidget {
  final String? roomId;
  final String title;
  final bool isHost;

  const VideoRoomScreen({
    super.key,
    this.roomId,
    this.title = 'Café da noite',
    this.isHost = false,
  });

  @override
  State<VideoRoomScreen> createState() => _VideoRoomScreenState();
}

class _VideoRoomScreenState extends State<VideoRoomScreen> {
  final ApiClient _api = ApiClient();
  final VideoService _videoService = VideoService();
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _showChat = false;
  int _currentQuestionIndex = 0;
  List<dynamic> _participants = [];
  List<String> _guidedQuestions = [];
  bool _loading = true;
  bool _inChannel = false;
  final List<int> _remoteUids = [];

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final hasPermission = await _videoService.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissões de câmera e microfone são necessárias')),
        );
      }
      return;
    }

    await _videoService.init();

    _videoService.onRemoteVideoJoined((uid) {
      if (mounted) setState(() => _remoteUids.add(uid));
    });

    _videoService.onRemoteVideoLeft((uid) {
      if (mounted) setState(() => _remoteUids.remove(uid));
    });

    await _loadRoom();
    await _joinChannel();
  }

  Future<void> _loadRoom() async {
    if (widget.roomId == null) {
      setState(() { _loading = false; _participants = [{'name': 'Você'}]; });
      return;
    }
    try {
      final room = await _api.get('/api/rooms/${widget.roomId}');
      final participants = room['participants'] ?? [];
      final questions = room['guided_questions'];
      if (mounted) {
        setState(() {
          _participants = participants.isNotEmpty ? participants : [{'name': 'Você'}];
          _guidedQuestions = questions is List
              ? List<String>.from(questions.map((q) => q.toString()))
              : ['Qual foi o melhor momento da sua semana?'];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _participants = [{'name': 'Você'}]; });
    }
  }

  Future<void> _joinChannel() async {
    final channelName = widget.roomId ?? 'default_room';
    final uid = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _videoService.joinChannel(
      channelName: channelName,
      token: '',
      uid: uid,
      isHost: widget.isHost,
    );

    if (mounted) setState(() => _inChannel = true);
  }

  void _nextQuestion() {
    if (_guidedQuestions.isEmpty) return;
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _guidedQuestions.length;
    });
  }

  Future<void> _leaveRoom() async {
    await _videoService.leaveChannel();
    if (widget.roomId != null) {
      try {
        if (widget.isHost) {
          await _api.post('/api/rooms/${widget.roomId}/end');
        } else {
          await _api.delete('/api/rooms/${widget.roomId}/leave');
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _videoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16)),
            Text('${_participants.length + _remoteUids.length} participantes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showChat ? Icons.chat : Icons.chat_outlined),
            onPressed: () => setState(() => _showChat = !_showChat),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showRoomOptions(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                if (_guidedQuestions.isNotEmpty)
                  GuidedQuestionsBar(
                    question: _guidedQuestions[_currentQuestionIndex],
                    onNext: _nextQuestion,
                  ),
                Expanded(
                  child: _showChat
                      ? Row(
                          children: [
                            Expanded(flex: 2, child: _buildVideoGrid()),
                            Expanded(flex: 1, child: RoomChatPanel(roomId: widget.roomId ?? '')),
                          ],
                        )
                      : _buildVideoGrid(),
                ),
                _buildControls(),
              ],
            ),
    );
  }

  Widget _buildVideoGrid() {
    final totalVideos = 1 + _remoteUids.length;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: totalVideos <= 2 ? 1 : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: totalVideos <= 2 ? 1.2 : 0.8,
      ),
      itemCount: totalVideos,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildLocalVideo();
        }
        return _buildRemoteVideo(_remoteUids[index - 1]);
      },
    );
  }

  Widget _buildLocalVideo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _videoService.engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
          if (_isVideoOff)
            Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: Icon(Icons.videocam_off, color: Colors.white, size: 48),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Você', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo(int uid) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _videoService.engine,
          canvas: VideoCanvas(uid: uid),
          connection: const RtcConnection(channelId: ''),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Desmutar' : 'Mutar',
            onTap: () async {
              await _videoService.toggleMute(!_isMuted);
              setState(() => _isMuted = !_isMuted);
            },
            color: _isMuted ? Colors.red : Colors.white,
          ),
          _ControlButton(
            icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
            label: _isVideoOff ? 'Ligar câmera' : 'Desligar câmera',
            onTap: () async {
              await _videoService.toggleVideo(!_isVideoOff);
              setState(() => _isVideoOff = !_isVideoOff);
            },
            color: _isVideoOff ? Colors.red : Colors.white,
          ),
          _ControlButton(
            icon: Icons.flip_camera_ios,
            label: 'Alternar câmera',
            onTap: () => _videoService.switchCamera(),
            color: Colors.white,
          ),
          _ControlButton(
            icon: Icons.exit_to_app,
            label: 'Sair',
            onTap: () => _showLeaveConfirmation(context),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  void _showRoomOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Denunciar sala'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartilhar sala'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da sala?'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await _leaveRoom();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}
