import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// White rounded container. Radius 18, padding 16×15 by default.
class PlainCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PlainCard({super.key, required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// A card that lays out rows with a 1px #F5EDDE divider between each (not after the last).
/// Card padding is 4×15 (rows provide their own vertical padding of 12).
class DividedCard extends StatelessWidget {
  final List<Widget> rows;

  const DividedCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(Container(height: 1, color: const Color(0xFFF5EDDE)));
      }
      children.add(rows[i]);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// Overview stat tile. Expands to fill (wrap in Expanded/Row by caller).
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor; // default AppColors.text

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: (AppType.numTabular.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.text,
            )),
          ),
        ],
      ),
    );
  }
}

/// Generic list row: leading avatar/icon, title+subtitle, right-aligned trailing.
class ListRowTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const ListRowTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final body = Row(
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.muted2)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: body,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: body,
    );
  }
}
