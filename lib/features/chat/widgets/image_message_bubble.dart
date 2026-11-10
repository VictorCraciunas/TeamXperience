import 'package:flutter/material.dart';
import 'package:teamxperience/ui/ui.dart';
import 'package:teamxperience/enums/photo_approval_status.dart';
import 'package:teamxperience/features/chat/widgets/full_screen_image.dart';
import 'bubble_position.dart';

class ImageMessageBubble extends StatelessWidget {
  final String imageUrl;
  final bool isMe;
  final BubblePosition position;
  final String? time;
  final bool showTime;
  final bool showApprovalActions;
  final PhotoApprovalStatus? status;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;

  /// The organiser's reason, shown under a rejected photo.
  final String? rejectReason;

  const ImageMessageBubble({
    super.key,
    required this.imageUrl,
    required this.isMe,
    this.position = BubblePosition.single,
    this.time,
    this.showTime = true,
    this.showApprovalActions = false,
    this.status,
    this.onApprove,
    this.onDeny,
    this.rejectReason,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: showTime ? 12 : 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: isMe ? context.colors.ctaGradient : null,
              color: isMe ? null : context.colors.panel,
              border: isMe
                  ? null
                  : Border.all(color: context.colors.border, width: 1.5),
              borderRadius: bubbleRadius(isMe, position),
              boxShadow: [
                if (isMe)
                  BoxShadow(
                    color: context.colors.navy.withValues(alpha: .2),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                else
                  BoxShadow(
                    color: context.colors.liveCard.withValues(alpha: .04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenImage(imageUrl: imageUrl),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: context.colors.insetBorder,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  color: context.colors.accent,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) => Container(
                              color: context.colors.insetBorder,
                              alignment: Alignment.center,
                              child: Icon(Icons.broken_image,
                                  color: context.colors.muted),
                            ),
                          ),
                        ),
                      ),
                      if (status != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _StatusChip(status: status!),
                        ),
                    ],
                  ),
                ),
                if (status == PhotoApprovalStatus.denied && (rejectReason ?? '').trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                    child: Text(
                      (rejectReason ?? '').trim(),
                      style: TextStyle(fontSize: 14, height: 1.4, color: context.colors.danger),
                    ),
                  ),
                if (showApprovalActions) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Aprobă',
                            icon: Icons.check_rounded,
                            filled: true,
                            onTap: onApprove,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ActionButton(
                            label: 'Respinge',
                            icon: Icons.close_rounded,
                            filled: false,
                            onTap: onDeny,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showTime && time != null)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                right: isMe ? 8 : 0,
                left: isMe ? 0 : 8,
              ),
              child: Text(
                time!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: context.colors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PhotoApprovalStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label, IconData icon) = switch (status) {
      PhotoApprovalStatus.pending => (
        context.colors.border,
        context.colors.warning,
        'În așteptare',
        Icons.access_time_rounded,
      ),
      PhotoApprovalStatus.approved => (
        context.colors.iconButtonBg,
        context.colors.accent,
        'Aprobat',
        Icons.check_rounded,
      ),
      PhotoApprovalStatus.denied => (
        context.colors.dangerSoft,
        context.colors.danger,
        'Respins',
        Icons.close_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
            child: Icon(icon, size: 10, color: context.colors.onNavy),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: filled ? context.colors.ctaGradient : null,
          color: filled ? null : context.colors.panel,
          border: filled
              ? null
              : Border.all(color: context.colors.border, width: 2),
          borderRadius: BorderRadius.circular(50),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: context.colors.navy.withValues(alpha: .25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: filled ? context.colors.onNavy : context.colors.text),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: filled ? context.colors.onNavy : context.colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
