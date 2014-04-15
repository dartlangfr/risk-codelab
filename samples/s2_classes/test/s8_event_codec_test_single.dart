library risk.event_codec.test;

import 'package:unittest/unittest.dart';
import 'package:risk_engine/risk_engine.dart';
import '../lib/risk.dart';

main() {
  test('serializable', () {
    // WHEN
    var output = EVENT.encode(new PlaceArmy()
        ..playerId = 1
        ..country = 'alaska');

    // THEN
    expect(output, equals({
      'event': 'PlaceArmy',
      'data': {
        'playerId': 1,
        'country': 'alaska'
      }
    }));
  });

  test('deserializable', () {
    // WHEN
    var output = EVENT.decode({
      'event': 'PlaceArmy',
      'data': {
        'playerId': 1,
        'country': 'alaska'
      }
    });

    // THEN
    expect(output is PlaceArmy, isTrue);
    expect(output.playerId, equals(1));
    expect(output.country, equals('alaska'));
  });
}
