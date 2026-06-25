import 'package:flutter/material.dart';

class VideoParticipantTile extends StatelessWidget {
  final String name;
  final bool isMuted;
  final bool isVideoOff;
  final bool isMe;

  const VideoParticipantTile({
    super.key,
    required this.name,
    this.isMuted = false,
    this.isVideoOff = false,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: isMe ? Border.all(color: const Color(0xFF4A7C6F), width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (isVideoOff)
              Center(
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF4A7C6F),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white38, size: 48),
                ),
              ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMuted)
                      const Icon(Icons.mic_off, color: Colors.red, size: 14)
                    else
                      const Icon(Icons.mic, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      isMe ? '$name (você)' : name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
