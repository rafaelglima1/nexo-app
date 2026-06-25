import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ReportType {
  harassment,
  spam,
  nudity,
  violence,
  other,
}

class ModerationService {
  final SupabaseClient _client;

  ModerationService(this._client);

  Future<bool> reportContent({
    required String reporterId,
    required String targetId,
    required ReportType type,
    String? description,
  }) async {
    try {
      await _client.from('reports').insert({
        'reporter_id': reporterId,
        'target_id': targetId,
        'type': type.name,
        'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> blockUser({
    required String userId,
    required String blockedUserId,
  }) async {
    try {
      await _client.from('blocked_users').insert({
        'user_id': userId,
        'blocked_user_id': blockedUserId,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserReports(String userId) async {
    try {
      return await _client
          .from('reports')
          .select()
          .eq('reporter_id', userId)
          .order('created_at', ascending: false);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getBlockedUsers(String userId) async {
    try {
      final response = await _client
          .from('blocked_users')
          .select('blocked_user_id')
          .eq('user_id', userId);
      return (response as List).map((r) => r['blocked_user_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> unblockUser({
    required String userId,
    required String blockedUserId,
  }) async {
    try {
      await _client
          .from('blocked_users')
          .delete()
          .eq('user_id', userId)
          .eq('blocked_user_id', blockedUserId);
    } catch (_) {}
  }

  static String getReportTypeName(ReportType type) {
    switch (type) {
      case ReportType.harassment:
        return 'Assédio ou bullying';
      case ReportType.spam:
        return 'Spam ou golpe';
      case ReportType.nudity:
        return 'Nudez ou conteúdo sexual';
      case ReportType.violence:
        return 'Violência ou ameaça';
      case ReportType.other:
        return 'Outro motivo';
    }
  }
}

class ReportDialog extends StatefulWidget {
  final String targetId;
  final String targetName;
  final String? reporterId;

  const ReportDialog({
    super.key,
    required this.targetId,
    required this.targetName,
    this.reporterId,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportType? _selectedType;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedType == null) return;

    setState(() => _isSubmitting = true);

    final supabase = Supabase.instance.client;
    final moderation = ModerationService(supabase);

    await moderation.reportContent(
      reporterId: widget.reporterId ?? supabase.auth.currentUser?.id ?? 'anonymous',
      targetId: widget.targetId,
      type: _selectedType!,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denúncia enviada. Obrigado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Denunciar ${widget.targetName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Motivo:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...ReportType.values.map((type) {
              final isSelected = _selectedType == type;
              return ListTile(
                title: Text(ModerationService.getReportTypeName(type)),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFF4A7C6F) : Colors.grey,
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () => setState(() => _selectedType = type),
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Descreva o problema (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _selectedType != null && !_isSubmitting ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enviar'),
        ),
      ],
    );
  }
}
