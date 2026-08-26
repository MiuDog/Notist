import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';

import 'model.dart';

class NtsCatalogShell extends StatelessWidget {
  const NtsCatalogShell({
    super.key,
    required this.pages,
    required this.selected,
    required this.onSelected,
  });

  final List<NtsCatalogPage> pages;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return KlpAppScreen(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          klp.space.compact,
          0,
          klp.space.compact,
          klp.space.compact,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: klp.geometry.layout.primaryPaneWidth,
              child: _CatalogNavigation(
                pages: pages,
                selected: selected,
                onSelected: onSelected,
              ),
            ),
            SizedBox(width: klp.space.compact),
            Expanded(child: _CatalogStage(page: pages[selected])),
          ],
        ),
      ),
    );
  }
}

class _CatalogNavigation extends StatelessWidget {
  const _CatalogNavigation({
    required this.pages,
    required this.selected,
    required this.onSelected,
  });

  final List<NtsCatalogPage> pages;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return KlpSurface(
      tone: KlpSurfaceTone.inset,
      child: KlpFileExplorer(
        sections: [
          KlpFileExplorerSection(
            id: 'notes',
            title: 'Notes',
            collapsible: false,
            items: [
              for (final page in pages)
                KlpFileExplorerItem(
                  id: page.label,
                  label: page.label,
                  icon: page.icon,
                  badge: '${page.specimens.length}',
                  selected: page == pages[selected],
                ),
            ],
          ),
        ],
        selectedId: pages[selected].label,
        onItemSelected: (id) {
          final index = pages.indexWhere((page) => page.label == id);
          if (index >= 0) onSelected(index);
        },
      ),
    );
  }
}

class _CatalogStage extends StatelessWidget {
  const _CatalogStage({required this.page});

  final NtsCatalogPage page;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return KlpSurface(
      tone: KlpSurfaceTone.inset,
      child: KlpScrollViewport(
        key: ValueKey('nts-catalog-${page.label.toLowerCase()}'),
        padding: EdgeInsets.all(klp.space.section),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KlpText(page.title, role: KlpTextRole.h1),
            SizedBox(height: klp.space.compact),
            KlpText(page.description, tone: KlpTextTone.muted),
            SizedBox(height: klp.space.section),
            for (var index = 0; index < page.specimens.length; index++) ...[
              _SpecimenBlock(specimen: page.specimens[index]),
              if (index < page.specimens.length - 1)
                SizedBox(height: klp.space.section),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpecimenBlock extends StatelessWidget {
  const _SpecimenBlock({required this.specimen});

  final NtsCatalogSpecimen specimen;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KlpText(specimen.name, role: KlpTextRole.h3),
        SizedBox(height: klp.space.tight),
        KlpText(
          specimen.states.join(' · '),
          role: KlpTextRole.caption,
          tone: KlpTextTone.faint,
        ),
        if (specimen.note != null) ...[
          SizedBox(height: klp.space.tight),
          KlpText(specimen.note!, tone: KlpTextTone.muted),
        ],
        SizedBox(height: klp.space.base),
        Builder(builder: specimen.build),
      ],
    );
  }
}
