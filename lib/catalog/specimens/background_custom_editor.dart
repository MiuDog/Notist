part of 'background_editor.dart';

class NtsBackgroundEditorSpecimen extends StatefulWidget {
  const NtsBackgroundEditorSpecimen({super.key});

  @override
  State<NtsBackgroundEditorSpecimen> createState() {
    return _NtsBackgroundEditorSpecimenState();
  }
}

class _NtsBackgroundEditorSpecimenState
    extends State<NtsBackgroundEditorSpecimen> {
  var _tool = NtsPageBackgroundEditorTool.connect;
  var _recipe = NtsCustomPageBackgroundRecipe(
    snapSpacing: 20,
    pointStyle: NtsPageBackgroundAxisStyle(width: 5),
    lineStyle: NtsPageBackgroundAxisStyle(width: 2),
  );

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: klp.space.itemGap,
          runSpacing: klp.space.itemGap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            KlpSegmentedControl(
              key: const ValueKey('background-editor-tool'),
              items: const ['點連', '選取', '刪除'],
              selected: _tool.index,
              onSelected: (value) {
                setState(
                  () => _tool = NtsPageBackgroundEditorTool.values[value],
                );
              },
            ),
            KlpButton(
              label: '清除背景',
              tone: KlpButtonTone.ghost,
              compact: true,
              onPressed: _recipe.points.isEmpty
                  ? null
                  : () {
                      setState(() {
                        _recipe = _recipe.copyWith(
                          points: const [],
                          lines: const [],
                        );
                      });
                    },
            ),
          ],
        ),
        SizedBox(height: klp.space.itemGap),
        const KlpText(
          '點擊建立節點並連線；按住 Shift 可暫停座標吸附。切換工具會結束目前連線。',
          role: KlpTextRole.sub,
          tone: KlpTextTone.muted,
        ),
        SizedBox(height: klp.space.groupGap),
        ClipRRect(
          borderRadius: BorderRadius.circular(klp.shape.card),
          child: SizedBox(
            height: klp.space.pageLarge * 4,
            child: NtsPageBackgroundEditor(
              recipe: _recipe,
              tool: _tool,
              onChanged: (value) => setState(() => _recipe = value),
            ),
          ),
        ),
      ],
    );
  }
}
