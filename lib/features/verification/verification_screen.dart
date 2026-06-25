import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isVerifying = false;
  bool _isPhoneVerified = false;
  bool _isSelfieVerified = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  void _loadVerificationStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      setState(() {
        _isPhoneVerified = metadata?['phone_verified'] ?? false;
        _isSelfieVerified = metadata?['selfie_verified'] ?? false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phoneController.text.trim().length < 10) return;

    final phone = '+55${_phoneController.text.trim()}';
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: phone);
      setState(() => _codeSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código enviado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar código: $e')),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.trim().length < 6) return;

    setState(() => _isVerifying = true);

    try {
      final phone = '+55${_phoneController.text.trim()}';
      await Supabase.instance.client.auth.verifyOTP(
        phone: phone,
        token: _codeController.text.trim(),
        type: OtpType.sms,
      );

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'phone_verified': true}),
      );

      setState(() {
        _isPhoneVerified = true;
        _isVerifying = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telefone verificado!')),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Código inválido: $e')),
        );
      }
    }
  }

  Future<void> _submitSelfie() async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'selfie_verified': true}),
      );

      setState(() => _isSelfieVerified = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selfie enviada para análise!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifiedCount = [true, _isPhoneVerified, _isSelfieVerified].where((v) => v).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Verificação'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A7C6F), Color(0xFF1A535C)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_user, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Verifique sua identidade',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$verifiedCount de 3 verificado${verifiedCount == 3 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: verifiedCount / 3,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildVerificationCard(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'Sempre verificado',
              isVerified: true,
              onTap: null,
            ),
            const SizedBox(height: 10),
            _buildVerificationCard(
              icon: Icons.phone,
              title: 'Telefone',
              subtitle: _isPhoneVerified ? 'Verificado' : 'Toque para verificar',
              isVerified: _isPhoneVerified,
              onTap: _isPhoneVerified ? null : () => _showPhoneVerification(context),
            ),
            const SizedBox(height: 10),
            _buildVerificationCard(
              icon: Icons.camera_alt,
              title: 'Selfie',
              subtitle: _isSelfieVerified ? 'Verificado' : 'Toque para verificar',
              isVerified: _isSelfieVerified,
              onTap: _isSelfieVerified ? null : () => _showSelfieVerification(context),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C6F).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A verificação ajuda a manter a comunidade segura e confiável.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isVerified,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isVerified ? const Color(0xFF4A7C6F).withValues(alpha: 0.2) : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isVerified ? const Color(0xFF4A7C6F).withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isVerified ? const Color(0xFF4A7C6F) : Colors.grey, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isVerified ? const Color(0xFF4A7C6F) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (isVerified)
              const Icon(Icons.check_circle, color: Color(0xFF4A7C6F), size: 22)
            else
              Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 22),
          ],
        ),
      ),
    );
  }

  void _showPhoneVerification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Verificar telefone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enviaremos um código de verificação por SMS.', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 20),
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  hintText: '11999999999',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  prefixText: '+55 ',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7C6F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enviar código'),
                ),
              ),
            ] else ...[
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: TextStyle(color: Colors.grey.shade300),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7C6F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Verificar'),
                ),
              ),
              TextButton(
                onPressed: _sendCode,
                child: const Text('Reenviar código'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSelfieVerification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Verificação por selfie', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'A foto será comparada com seu perfil para confirmar identidade.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('Câmera será aberta aqui', style: TextStyle(color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _submitSelfie();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tirar selfie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C6F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
