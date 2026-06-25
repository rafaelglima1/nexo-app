import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/presentation/auth_provider.dart' as ap;
import '../auth/presentation/login_screen.dart';
import 'security_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection('Conta', [
            _SettingsTile(icon: Icons.person_outline, title: 'Editar perfil', onTap: () {}),
            _SettingsTile(icon: Icons.lock_outline, title: 'Alterar senha', onTap: () {}),
            _SettingsTile(icon: Icons.email_outlined, title: 'Alterar email', onTap: () {}),
          ]),
          const SizedBox(height: 20),
          _buildSection('Preferências', [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notificações',
              trailing: Switch(
                value: true,
                onChanged: (v) {},
                activeThumbColor: const Color(0xFF4A7C6F),
              ),
            ),
            _SettingsTile(icon: Icons.language, title: 'Idioma', subtitle: 'Português', onTap: () {}),
            _SettingsTile(icon: Icons.dark_mode_outlined, title: 'Tema', subtitle: 'Claro', onTap: () {}),
          ]),
          const SizedBox(height: 20),
          _buildSection('Privacidade e Segurança', [
            _SettingsTile(
              icon: Icons.security,
              title: 'Segurança e denúncias',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
            ),
            _SettingsTile(icon: Icons.block, title: 'Usuários bloqueados', onTap: () {}),
            _SettingsTile(icon: Icons.privacy_tip_outlined, title: 'Política de privacidade', onTap: () {}),
            _SettingsTile(icon: Icons.description_outlined, title: 'Termos de uso', onTap: () {}),
            _SettingsTile(icon: Icons.download, title: 'Exportar dados', subtitle: 'LGPD', onTap: () {}),
          ]),
          const SizedBox(height: 20),
          _buildSection('Sobre', [
            _SettingsTile(icon: Icons.info_outline, title: 'Versão', subtitle: '1.0.0+1'),
            _SettingsTile(icon: Icons.help_outline, title: 'Central de ajuda', onTap: () {}),
            _SettingsTile(icon: Icons.feedback_outlined, title: 'Enviar feedback', onTap: () {}),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteAccount(context),
              icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
              label: const Text('Excluir conta', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final auth = context.read<ap.AuthProvider>();
                await auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A7C6F)),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir conta?'),
        content: const Text('Esta ação é irreversível. Todos os seus dados serão permanentemente removidos, incluindo perfil, interesses, mensagens, participações em salas e eventos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = context.read<ap.AuthProvider>();
              await auth.deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Excluir permanentemente', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: Colors.grey.shade600, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))
          : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20) : null),
      onTap: onTap,
    );
  }
}
