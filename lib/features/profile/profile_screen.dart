import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../auth/presentation/auth_provider.dart' as ap;
import '../auth/presentation/login_screen.dart';
import '../settings/settings_screen.dart';
import '../verification/verification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiClient _api = ApiClient();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _api.get('/api/users/me');
      if (mounted) setState(() { _profile = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<ap.AuthProvider>();
    final user = auth.currentUser;

    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C6F)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A7C6F), Color(0xFF1A535C)],
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white24,
                          backgroundImage: _profile?['avatar_url'] != null
                              ? NetworkImage(_profile!['avatar_url'])
                              : null,
                          child: _profile?['avatar_url'] == null
                              ? const Icon(Icons.person, size: 48, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _profile?['name'] ?? user?.email ?? 'Usuário',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        if (_profile?['is_verified'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Verificado', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.interests,
                          title: 'Interesses',
                          subtitle: _buildInterestsText(),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoCard(
                          icon: Icons.psychology,
                          title: 'Personalidade',
                          subtitle: _profile?['personality'] ?? 'Não definida',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoCard(
                          icon: Icons.explore,
                          title: 'Tipo de experiência',
                          subtitle: _profile?['experience_type'] ?? 'Não definido',
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Conta'),
                        const SizedBox(height: 8),
                        _buildMenuTile(
                          icon: Icons.settings_outlined,
                          title: 'Configurações',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        ),
                        _buildMenuTile(
                          icon: Icons.verified_user_outlined,
                          title: 'Verificação',
                          subtitle: 'Email verificado',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationScreen())),
                        ),
                        _buildMenuTile(
                          icon: Icons.help_outline,
                          title: 'Ajuda',
                          onTap: () {},
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await auth.signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (_) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const Text('Sair da conta', style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _buildInterestsText() {
    final interests = _profile?['user_interests'];
    if (interests == null || interests is! List || interests.isEmpty) return 'Nenhum interesse';
    return interests.map((i) => i['interests']?['name'] ?? '').where((s) => s.isNotEmpty).join(', ');
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF4A7C6F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF4A7C6F)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4A7C6F)),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 13)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
