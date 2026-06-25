import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
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
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _showChat = false;
  int _currentQuestionIndex = 0;
  List<dynamic> _participants = [];
  List<String> _guidedQuestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoom();
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

  void _nextQuestion() {
    if (_guidedQuestions.isEmpty) return;
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _guidedQuestions.length;
    });
  }

  Future<void> _leaveRoom() async {
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
            Text('${_participants.length} participantes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _participants.length <= 2 ? 1 : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: _participants.length <= 2 ? 1.2 : 0.8,
      ),
      itemCount: _participants.length,
      itemBuilder: (context, index) {
        final p = _participants[index];
        final name = p['name'] ?? p['users']?['name'] ?? 'Participante';
        final isMe = index == _participants.length - 1;
        return VideoParticipantTile(
          name: name,
          isMuted: isMe ? _isMuted : false,
          isVideoOff: isMe ? _isVideoOff : false,
          isMe: isMe,
        );
      },
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
            onTap: () => setState(() => _isMuted = !_isMuted),
            color: _isMuted ? Colors.red : Colors.white,
          ),
          _ControlButton(
            icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
            label: _isVideoOff ? 'Ligar câmera' : 'Desligar câmera',
            onTap: () => setState(() => _isVideoOff = !_isVideoOff),
            color: _isVideoOff ? Colors.red : Colors.white,
          ),
          _ControlButton(
            icon: Icons.flip_camera_ios,
            label: 'Alternar câmera',
            onTap: () {},
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
