import 'package:flutter/material.dart';
import 'package:teamxperience/features/chat/widgets/full_screen_image.dart';

class ImageMessageBubble extends StatelessWidget {
  final String sender;
  final String imageUrl;
  final bool isMe;
  final bool showApprovalActions;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;

  const ImageMessageBubble({
    super.key,
    required this.sender,
    required this.imageUrl,
    required this.isMe,
    this.showApprovalActions = false,
    this.onApprove,
    this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FullScreenImage(imageUrl: imageUrl),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 220,
                    height: 220,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stack) => Container(
                  width: 220,
                  height: 220,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.black38),
                ),
              ),
            ),
          ),
          if (showApprovalActions) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Aprobă'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onApprove,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Respinge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onDeny,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
