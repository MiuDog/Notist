import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

class NtsCatalogGrid extends StatelessWidget {
  const NtsCatalogGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final klp = context.klp;
        final count =
            constraints.maxWidth < klp.geometry.layout.primaryPaneBreakpoint
            ? 1
            : 2;
        final width =
            (constraints.maxWidth - klp.space.itemGap * (count - 1)) / count;

        return Wrap(
          spacing: klp.space.itemGap,
          runSpacing: klp.space.itemGap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class NtsCatalogSample extends StatelessWidget {
  const NtsCatalogSample({
    super.key,
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return KlpSurface(
      tone: KlpSurfaceTone.component,
      padding: EdgeInsets.all(klp.space.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KlpText(label, role: KlpTextRole.bodyStrong),
          if (description != null) ...[
            SizedBox(height: klp.space.tight),
            KlpText(description!, tone: KlpTextTone.muted),
          ],
          SizedBox(height: klp.space.base),
          child,
        ],
      ),
    );
  }
}
