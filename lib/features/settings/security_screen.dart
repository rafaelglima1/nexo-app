import 'package:flutter/material.dart';
import '../../core/moderation/moderation_service.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segurança e Denúncias')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A7C6F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield, color: Color(0xFF4A7C6F)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seu ambiente é seguro', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Monitoramos continuamente para manter a comunidade segura.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Denúncias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ReportCard(
            type: 'Assédio',
            target: 'Usuário123',
            date: '15 Jun 2026',
            status: 'Em análise',
            statusColor: Colors.orange,
          ),
          _ReportCard(
            type: 'Spam',
            target: 'Sala: Promoção',
            date: '10 Jun 2026',
            status: 'Resolvido',
            statusColor: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text('Ações de segurança', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.person_remove,
            title: 'Gerenciar bloqueios',
            subtitle: '3 usuários bloqueados',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.flag,
            title: 'Fazer uma denúncia',
            subtitle: 'Reportar comportamento inadequado',
            onTap: () => _showReportDialog(context),
          ),
          _ActionTile(
            icon: Icons.help_outline,
            title: 'Central de segurança',
            subtitle: 'Dicas e recursos de segurança',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.gavel,
            title: 'Diretrizes da comunidade',
            subtitle: 'Nossas regras e valores',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const Text('Verificação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _VerificationTile(
            icon: Icons.email,
            title: 'Email',
            isVerified: true,
          ),
          _VerificationTile(
            icon: Icons.phone,
            title: 'Telefone',
            isVerified: false,
            onTap: () {},
          ),
          _VerificationTile(
            icon: Icons.camera_alt,
            title: 'Selfie',
            isVerified: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportDialog(targetId: 'general', targetName: 'conteúdo'),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String type;
  final String target;
  final String date;
  final String status;
  final Color statusColor;

  const _ReportCard({
    required this.type,
    required this.target,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.flag, color: statusColor),
        ),
        title: Text(type),
        subtitle: Text('$target • $date'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4A7C6F)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _VerificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isVerified;
  final VoidCallback? onTap;

  const _VerificationTile({
    required this.icon,
    required this.title,
    required this.isVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isVerified ? const Color(0xFF4A7C6F) : Colors.grey),
        title: Text(title),
        trailing: isVerified
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF4A7C6F)),
                  SizedBox(width: 4),
                  Text('Verificado', style: TextStyle(color: Color(0xFF4A7C6F), fontSize: 12)),
                ],
              )
            : TextButton(
                onPressed: onTap,
                child: const Text('Verificar'),
              ),
      ),
    );
  }
}
