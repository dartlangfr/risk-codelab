import 'package:unittest/html_config.dart';
import 'map_tests.dart' as map_tests;
import 'game_tests.dart' as game_tests;
import 'engine_tests.dart' as engine_tests;
import 'event_tests.dart' as event_tests;

main() {
  useHtmlConfiguration();
  map_tests.main();
  game_tests.main();
  engine_tests.main();
  event_tests.main();
}