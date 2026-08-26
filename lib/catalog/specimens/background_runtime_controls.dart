part of 'background_editor.dart';

extension _NtsBackgroundRuntimeControls on _NtsBackgroundRuntimeSpecimenState {
  Widget _buildGeometryPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KlpSegmentedControl(
          key: const ValueKey('background-stroke-behavior'),
          items: const ['恆定線寬', '跟隨縮放'],
          selected: _strokeBehavior == NtsPageBackgroundStrokeBehavior.fixed
              ? 0
              : 1,
          expanded: true,
          onSelected: (value) => _update(() {
            _strokeBehavior = value == 0
                ? NtsPageBackgroundStrokeBehavior.fixed
                : NtsPageBackgroundStrokeBehavior.scaled;
          }),
        ),
        KlpSlider(
          key: const ValueKey('background-axis-width'),
          label: _kind == 0 ? '線寬' : '${_axis == 0 ? '次要軸' : '主要軸'}寬度',
          value: _axis == 0 ? _minorWidth : _majorWidth,
          min: 1,
          max: 8,
          divisions: 7,
          displayValue:
              '${(_axis == 0 ? _minorWidth : _majorWidth).round()} px',
          onChanged: (value) => _update(() {
            if (_axis == 0 || _kind == 0) {
              _minorWidth = value;
            } else {
              _majorWidth = value;
            }
          }),
        ),
        KlpSlider(
          key: const ValueKey('background-major-spacing'),
          label: _kind == 0 ? '線條間距' : '主要軸間距',
          value: _majorSpacing,
          min: 24,
          max: 120,
          divisions: 12,
          displayValue: '${_majorSpacing.round()} px',
          onChanged: (value) => _update(() => _majorSpacing = value),
        ),
        if (_kind > 0)
          KlpSlider(
            key: const ValueKey('background-minor-count'),
            label: '內部分割',
            value: _minorAxisCount.toDouble(),
            min: 0,
            max: 8,
            divisions: 8,
            displayValue: '$_minorAxisCount',
            onChanged: (value) {
              _update(() => _minorAxisCount = value.round());
            },
          ),
        KlpSlider(
          key: const ValueKey('background-zoom'),
          label: 'Viewport zoom',
          value: _zoom,
          min: 0.5,
          max: 2,
          divisions: 6,
          displayValue: '${(_zoom * 100).round()}%',
          onChanged: (value) => _update(() => _zoom = value),
        ),
      ],
    );
  }

  NtsPageBackgroundRecipe _buildRecipe(Color minor, Color major) {
    final minorAxis = NtsPageBackgroundAxisStyle(
      color: minor,
      width: _minorWidth,
    );
    final majorAxis = NtsPageBackgroundAxisStyle(
      color: major,
      width: _majorWidth,
    );

    return switch (_kind) {
      0 => NtsRuledPageBackgroundRecipe(
        axis: minorAxis,
        spacing: _majorSpacing,
        strokeBehavior: _strokeBehavior,
      ),
      1 => NtsDotsPageBackgroundRecipe(
        minorAxis: minorAxis,
        majorAxis: majorAxis,
        majorSpacing: _majorSpacing,
        minorAxisCount: _minorAxisCount,
        strokeBehavior: _strokeBehavior,
      ),
      _ => NtsGridPageBackgroundRecipe(
        minorAxis: minorAxis,
        majorAxis: majorAxis,
        majorSpacing: _majorSpacing,
        minorAxisCount: _minorAxisCount,
        strokeBehavior: _strokeBehavior,
      ),
    };
  }

  void _setColorChannel(int channel, int value) {
    final fallback = context.klp.color.pagePattern;
    final current = _axis == 0
        ? (_minorColor ?? fallback)
        : (_majorColor ?? fallback);
    final channels = [
      (current.r * 255).round(),
      (current.g * 255).round(),
      (current.b * 255).round(),
      (current.a * 255).round(),
    ];
    channels[channel] = value;
    final changed = Color.fromARGB(
      channels[3],
      channels[0],
      channels[1],
      channels[2],
    );
    _update(() {
      if (_axis == 0 || _kind == 0) {
        _minorColor = changed;
      } else {
        _majorColor = changed;
      }
    });
  }
}
