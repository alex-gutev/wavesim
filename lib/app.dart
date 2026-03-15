import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/simulation/simulation.dart';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {

  @override
  void initState() {
    super.initState();
    // Run code depending on the rendering environment.
    if (kIsWeb) {
      print("Hello client");
    } else {
      print("Hello server");
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'main', [
      Router(routes: [
        ShellRoute(
          builder: (context, state, child) => fragment([
            // TODO: Add navigation
            child,
          ]),
          routes: [
            Route(
                path: '/',
                title: 'Wavesim2D',
                builder: (context, state) => const Simulation()
            ),
          ],
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.main', [
      css('&').styles(
        display: Display.flex,
        height: 100.vh,
        flexDirection: FlexDirection.column,
        overflow: Overflow.scroll
      ),
      css('section').styles(
        display: Display.flex,
        flexDirection: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        flex: Flex(grow: 1),
      ),
    ]),
  ];
}
