import 'package:flutter/material.dart';
import 'package:kallopis/kallopis.dart';
import 'package:notist/notist.dart';

part 'background_custom_editor.dart';
part 'background_runtime_controls.dart';

/// Catalog 專用的執行期 recipe 控制面板。
class NtsBackgroundRuntimeSpecimen extends StatefulWidget {
  const NtsBackgroundRuntimeSpecimen({super.key});

  @override
  State<NtsBackgroundRuntimeSpecimen> createState() {
    return _NtsBackgroundRuntimeSpecimenState();
  }
}

class _NtsBackgroundRuntimeSpecimenState
    extends State<NtsBackgroundRuntimeSpecimen> {
  var _kind = 1;
  var _axis = 0;
  Color? _minorColor;
  Color? _majorColor;
  var _minorWidth = 1.0;
  var _majorWidth = 3.0;
  var _majorSpacing = 64.0;
  var _minorAxisCount = 3;
  var _zoom = 1.0;
  var _strokeBehavior = NtsPageBackgroundStrokeBehavior.fixed;

  void _update(VoidCallback change) {
    setState(change);
  }

  @override
  Widget build(BuildContext context) {
    final klp = context.klp;
    final minorColor = _minorColor ?? klp.color.pagePattern;
    final majorColor = _majorColor ?? klp.color.pagePattern;
    final recipe = _buildRecipe(minorColor, majorColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KlpSegmentedControl(
          key: const ValueKey('background-kind'),
          items: const ['Ruled', 'Dots', 'Grid'],
          selected: _kind,
          expanded: true,
          onSelected: (value) => setState(() => _kind = value),
        ),
        SizedBox(height: klp.space.groupGap),
        ClipRRect(
          borderRadius: BorderRadius.circular(klp.shape.card),
          child: NtsPageBackground.recipe(
            recipe: recipe,
            viewport: NtsPageBackgroundViewport(scale: _zoom),
            child: SizedBox(height: klp.space.pageLarge * 3),
          ),
        ),
        SizedBox(height: klp.space.groupGap),
        LayoutBuilder(
          builder: (context, constraints) {
            final panelWidth = constraints.maxWidth >= 720
                ? (constraints.maxWidth - klp.space.groupGap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: klp.space.groupGap,
              runSpacing: klp.space.groupGap,
              children: [
                SizedBox(
                  width: panelWidth,
                  child: _buildColorPanel(context, minorColor, majorColor),
                ),
                SizedBox(width: panelWidth, child: _buildGeometryPanel()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildColorPanel(
    BuildContext context,
    Color minorColor,
    Color majorColor,
  ) {
    final klp = context.klp;
    final selectedColor = _axis == 0 ? minorColor : majorColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_kind > 0) ...[
          KlpSegmentedControl(
            key: const ValueKey('background-axis'),
            items: const ['次要軸', '主要軸'],
            selected: _axis,
            expanded: true,
            onSelected: (value) => setState(() => _axis = value),
          ),
          SizedBox(height: klp.space.itemGap),
        ],
        Row(
          children: [
            Expanded(
              child: KlpText(
                _kind == 0 ? '線條 RGBA' : '${_axis == 0 ? '次要軸' : '主要軸'} RGBA',
                role: KlpTextRole.bodyStrong,
              ),
            ),
            Container(
              key: const ValueKey('background-color-swatch'),
              width: klp.space.iconLarge,
              height: klp.space.iconLarge,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(klp.shape.control),
              ),
            ),
          ],
        ),
        SizedBox(height: klp.space.itemGap),
        _colorSlider('R', selectedColor.r, 0),
        _colorSlider('G', selectedColor.g, 1),
        _colorSlider('B', selectedColor.b, 2),
        _colorSlider('A', selectedColor.a, 3),
      ],
    );
  }

  Widget _colorSlider(String label, double value, int channel) {
    return KlpSlider(
      key: ValueKey('background-${label.toLowerCase()}'),
      label: label,
      value: value * 255,
      min: 0,
      max: 255,
      divisions: 255,
      displayValue: (value * 255).round().toString(),
      onChanged: (next) => _setColorChannel(channel, next.round()),
    );
  }
}
