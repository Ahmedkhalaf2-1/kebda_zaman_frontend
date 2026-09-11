import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// A universal header for all Admin screens to enforce consistent spacing,
/// typography, and action placement.
///
/// Use [title] for the main screen name, and optional [subtitle] for context.
/// Use [primaryAction] for the main button (e.g. Save, Create).
/// Use [trailingActions] for secondary actions (e.g. Refresh, Filter).
class AdminPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? primaryAction;
  final List<Widget>? trailingActions;
  final bool showBackButton;

  const AdminPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.primaryAction,
    this.trailingActions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KZ.screenPadding,
        KZ.sp16,
        KZ.screenPadding,
        KZ.sp16,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTitleBlock()),
                    if (trailingActions != null && trailingActions!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: trailingActions!,
                      ),
                  ],
                ),
                if (primaryAction != null) ...[
                  const SizedBox(height: KZ.sp12),
                  SizedBox(width: double.infinity, child: primaryAction!),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildTitleBlock()),
              const SizedBox(width: KZ.sp16),
              if (trailingActions != null) ...[
                for (final action in trailingActions!) ...[
                  action,
                  const SizedBox(width: KZ.sp8),
                ],
                const SizedBox(width: KZ.sp8),
              ],
              if (primaryAction != null) primaryAction!,
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showBackButton) ...[
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: KZ.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: KZ.sp8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: KZ.pageTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
