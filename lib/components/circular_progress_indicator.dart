import 'package:jaspr/jaspr.dart';

/// An indeterminate rotating loading indicator
class CircularProgressIndicator extends StatelessComponent {
  final String? classes;

  const CircularProgressIndicator({
    super.key,
    this.classes
  });

  String get _classes => classes != null
      ? 'circular-loading-indicator $classes'
      : 'circular-loading-indicator';

  @override
  Component build(BuildContext context) {
    return svg(
        classes: _classes,
        viewBox: '0 0 44 44',
        [
          circle(
              classes: 'path',
              cx: '22',
              cy: '22',
              r: '20',
              fill: Color('none'),
              strokeWidth: '4',

              attributes: {
                'stroke-miterlimit': '10'
              },

              []
          )
        ]
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.circular-loading-indicator', [
      css('&').styles(
          height: 1.em,
          width: 1.em,
          position: Position.relative(),
          raw: {
            'animation': 'rotate 2s linear infinite'
          }
      ),

      css('.path').styles(
          raw: {
            'stroke-dasharray': '1,200',
            'stroke-dashoffset': '0',
            'stroke': '#B6463A',
            'stroke-linecap': 'round',

            'animation': 'dash 1.5s ease-in-out infinite, '
                'color 6s ease-in-out infinite'
          }
      )
    ]),
    
    css.keyframes('rotate', {
      '100%': Styles(
        transform: Transform.rotate(360.deg)
      )
    }),

    css.keyframes('dash', {
      '0%': Styles(
        raw: {
          'stroke-dasharray': '1,200',
          'stroke-dashoffset': '0',
        }
      ),
      '50%': Styles(
          raw: {
            'stroke-dasharray': '89,200',
            'stroke-dashoffset': '-35',
          }
      ),
      '100%': Styles(
          raw: {
            'stroke-dasharray': '89,200',
            'stroke-dashoffset': '-124',
          }
      )
    }),

    css.keyframes('color', {
      '100%,0%': Styles(
        raw: {
          'stroke': '#d62d20'
        }
      ),
      '40%': Styles(
        raw: {
          'stroke': '#0057e7'
        }
      ),
      '66%': Styles(
        raw: {
          'stroke': '#008744'
        }
      ),
      '80%, 90%': Styles(
        raw: {
          'stroke': '#ffa700'
        }
      )
    })
  ];
}