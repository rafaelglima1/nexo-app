import 'package:flutter/material.dart';

class GroupMoviesScreen extends StatelessWidget {
  const GroupMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filmes em Grupo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Próximas sessões', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _MovieSessionCard(
              title: 'Domingo de Cinema',
              movie: 'Cidade de Deus',
              time: 'Domingo, 15:00',
              participants: 12,
              maxParticipants: 20,
              isLive: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieRoomScreen(title: 'Domingo de Cinema')),
              ),
            ),
            _MovieSessionCard(
              title: 'Terror Night',
              movie: 'O Chamado',
              time: 'Sexta, 22:00',
              participants: 8,
              maxParticipants: 15,
              isLive: false,
              onTap: () {},
            ),
            _MovieSessionCard(
              title: 'Clássicos Brasileiros',
              movie: 'Central do Brasil',
              time: 'Sábado, 20:00',
              participants: 5,
              maxParticipants: 10,
              isLive: false,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text('Ao vivo agora', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _MovieSessionCard(
              title: 'Filme de Terror',
              movie: 'Invocação do Mal',
              time: 'Ao vivo',
              participants: 6,
              maxParticipants: 15,
              isLive: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieRoomScreen(title: 'Filme de Terror')),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Sugeridos para você', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _SuggestedMovieCard(title: 'O Auto da Compadecida', genre: 'Comédia', icon: '🎭'),
                  SizedBox(width: 12),
                  _SuggestedMovieCard(title: 'Tropa de Elite', genre: 'Ação', icon: '🎬'),
                  SizedBox(width: 12),
                  _SuggestedMovieCard(title: 'Carandiru', genre: 'Drama', icon: '🎭'),
                  SizedBox(width: 12),
                  _SuggestedMovieCard(title: 'O Mecanismo', genre: 'Suspense', icon: '🎬'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSession(context),
        icon: const Icon(Icons.add),
        label: const Text('Criar sessão'),
        backgroundColor: const Color(0xFF4A7C6F),
      ),
    );
  }

  void _showCreateSession(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nova sessão', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(hintText: 'Nome da sessão', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(hintText: 'Nome do filme', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(hintText: 'Data e hora', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Criar sessão'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieSessionCard extends StatelessWidget {
  final String title;
  final String movie;
  final String time;
  final int participants;
  final int maxParticipants;
  final bool isLive;
  final VoidCallback? onTap;

  const _MovieSessionCard({
    required this.title,
    required this.movie,
    required this.time,
    required this.participants,
    required this.maxParticipants,
    this.isLive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.red : const Color(0xFF4A7C6F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLive ? '🔴 AO VIVO' : time,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text('$participants/$maxParticipants', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('🎬 $movie', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: participants / maxParticipants,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF4A7C6F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestedMovieCard extends StatelessWidget {
  final String title;
  final String genre;
  final String icon;

  const _SuggestedMovieCard({required this.title, required this.genre, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(genre, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class MovieRoomScreen extends StatefulWidget {
  final String title;

  const MovieRoomScreen({super.key, required this.title});

  @override
  State<MovieRoomScreen> createState() => _MovieRoomScreenState();
}

class _MovieRoomScreenState extends State<MovieRoomScreen> {
  final _chatController = TextEditingController();
  final _messages = <_ChatMessage>[
    _ChatMessage(sender: 'Ana', text: 'Começou!', time: '15:01'),
    _ChatMessage(sender: 'Bruno', text: 'Esse filme é muito bom', time: '15:05'),
  ];

  @override
  void dispose() {
    _chatController.dispose();
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
            const Text('6 assistindo', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.people), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.movie, size: 80, color: Colors.white38),
                    SizedBox(height: 16),
                    Text('Player de vídeo', style: TextStyle(color: Colors.white38, fontSize: 18)),
                    Text('(Integração com streaming)', style: TextStyle(color: Colors.white24)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${msg.sender}: ',
                                  style: const TextStyle(color: Color(0xFF4A7C6F), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                TextSpan(
                                  text: msg.text,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Comentar...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white10,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.send, color: Color(0xFF4A7C6F)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String sender;
  final String text;
  final String time;

  _ChatMessage({required this.sender, required this.text, required this.time});
}
