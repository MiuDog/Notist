import 'package:flutter/widgets.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

/// 以 Kallopis 點陣背景與通用表面組裝的 Canva 筆記頁。
class NotistCanvaPage extends StatelessWidget {
  const NotistCanvaPage({super.key, required this.noteTitle});

  final String noteTitle;

  @override
  Widget build(BuildContext context) {
    return NtsPageBackground(
      key: const ValueKey('notist-canva-page'),
      style: NtsPageBackgroundStyle.dots,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final klp = context.klp;
          final compact =
              constraints.maxWidth < klp.geometry.layout.inlineNoticeBreakpoint;

          return compact
              ? _CompactCanva(noteTitle: noteTitle)
              : _SpatialCanva(noteTitle: noteTitle);
        },
      ),
    );
  }
}

class _CompactCanva extends StatelessWidget {
  const _CompactCanva({required this.noteTitle});

  final String noteTitle;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return KlpScrollViewport(
      padding: EdgeInsets.all(klp.space.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BoardHeading(noteTitle: noteTitle),
          SizedBox(height: klp.space.base),
          const _IdeaCard(
            title: 'LOOK FOR',
            body: 'Warm light · linen shade · small footprint',
          ),
          SizedBox(height: klp.space.base),
          const _IdeaCard(
            title: 'REMEMBER',
            body: 'Bring the shelf measurements.',
            tone: KlpSurfaceTone.accentSoft,
          ),
        ],
      ),
    );
  }
}

class _SpatialCanva extends StatelessWidget {
  const _SpatialCanva({required this.noteTitle});

  final String noteTitle;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return Padding(
      padding: EdgeInsets.all(klp.space.section),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _BoardHeading(noteTitle: noteTitle),
          ),
          const Align(
            alignment: Alignment(-0.65, -0.35),
            child: _IdeaCard(
              title: 'LOOK FOR',
              body: 'Warm light\nLinen shade\nSmall footprint',
            ),
          ),
          const Align(
            alignment: Alignment(0.55, -0.05),
            child: _IdeaCard(
              title: 'MOOD',
              body: 'Quiet corners and soft pools of light.',
              tone: KlpSurfaceTone.raised,
            ),
          ),
          const Align(
            alignment: Alignment(-0.1, 0.62),
            child: _IdeaCard(
              title: 'REMEMBER',
              body: 'Bring the shelf measurements.',
              tone: KlpSurfaceTone.accentSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardHeading extends StatelessWidget {
  const _BoardHeading({required this.noteTitle});

  final String noteTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const KlpText('CANVA', role: KlpTextRole.code, tone: KlpTextTone.faint),
        KlpText(noteTitle, role: KlpTextRole.display),
      ],
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({
    required this.title,
    required this.body,
    this.tone = KlpSurfaceTone.component,
  });

  final String title;
  final String body;
  final KlpSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return SizedBox(
      width: klp.space.pageLarge * 3,
      child: KlpSurface(
        tone: tone,
        padding: EdgeInsets.all(klp.space.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            KlpText(title, role: KlpTextRole.label),
            SizedBox(height: klp.space.compact),
            KlpText(body, role: KlpTextRole.editor),
          ],
        ),
      ),
    );
  }
}
