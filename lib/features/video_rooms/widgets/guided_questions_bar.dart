import 'package:flutter/material.dart';

class GuidedQuestionsBar extends StatelessWidget {
  final String question;
  final VoidCallback onNext;

  const GuidedQuestionsBar({
    super.key,
    required this.question,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF4A7C6F).withValues(alpha: 0.2),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF4A7C6F), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C6F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Próxima', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
