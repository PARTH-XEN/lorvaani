import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/comic_colors.dart';
import '../../../core/theme/comic_typography.dart';
import '../../../core/widgets/comic_panel.dart';
import '../../../core/widgets/badge_chip.dart';

/// Subject Card with unique color identity and comic panel borders
class SubjectCard extends StatelessWidget {
  final SubjectItem subject;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ComicPanel(
      backgroundColor: ComicColors.cardBackground,
      borderColor: subject.color.withValues(alpha: 0.7),
      borderRadius: 16,
      borderWidth: 2,
      padding: const EdgeInsets.all(12),
      shadowOffset: const Offset(3, 3),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: subject.color, width: 1.5),
                ),
                child: Icon(
                  subject.icon,
                  color: subject.color,
                  size: 20,
                ),
              ),
              BadgeChip.category(
                name: '${subject.storiesCount}',
                color: subject.color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.title,
                style: ComicTypography.title(fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                subject.subtitle,
                style: ComicTypography.caption(
                  fontSize: 11,
                  color: ComicColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
