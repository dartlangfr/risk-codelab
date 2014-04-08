library risk.event.test;

import 'package:unittest/unittest.dart';
import 'package:risk_engine/server.dart';
import 'package:risk/risk.dart';

var events = {
  "JoinGame": new SerializableTest()
      ..event = (new JoinGame()
          ..playerId = 123
          ..name = "John Lennon"
          ..avatar = "kadhafi.png")
      ..json = {
        "event": "JoinGame",
        "data": {
          "playerId": 123,
          "name": "John Lennon",
          "avatar": "kadhafi.png",
        },
      }
      ..expectation = (JoinGame event, JoinGame output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.name, equals(event.name));
        expect(output.avatar, equals(event.avatar));
      },

  "StartGame": new SerializableTest()
      ..event = (new StartGame()..playerId = 123)
      ..json = {
        "event": "StartGame",
        "data": {
          "playerId": 123,
        },
      }
      ..expectation = (StartGame event, StartGame output) {
        expect(output.playerId, equals(event.playerId));
      },

  "PlaceArmy": new SerializableTest()
      ..event = (new PlaceArmy()
          ..playerId = 123
          ..country = "eastern_australia")
      ..json = {
        "event": "PlaceArmy",
        "data": {
          "playerId": 123,
          "country": "eastern_australia"
        },
      }
      ..expectation = (PlaceArmy event, PlaceArmy output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.country, equals(event.country));
      },

  "Attack": new SerializableTest()
      ..event = (new Attack()
          ..playerId = 123
          ..from = "eastern_australia"
          ..to = "western_australia"
          ..armies = 3)
      ..json = {
        "event": "Attack",
        "data": {
          "playerId": 123,
          "from": "eastern_australia",
          "to": "western_australia",
          "armies": 3
        },
      }
      ..expectation = (Attack event, Attack output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.from, equals(event.from));
        expect(output.to, equals(event.to));
        expect(output.armies, equals(event.armies));
      },

  "EndAttack": new SerializableTest()
      ..event = (new EndAttack()..playerId = 123)
      ..json = {
        "event": "EndAttack",
        "data": {
          "playerId": 123,
        },
      }
      ..expectation = (EndAttack event, EndAttack output) {
        expect(output.playerId, equals(event.playerId));
      },

  "MoveArmy": new SerializableTest()
      ..event = (new MoveArmy()
          ..playerId = 123
          ..from = "eastern_australia"
          ..to = "western_australia"
          ..armies = 3)
      ..json = {
        "event": "MoveArmy",
        "data": {
          "playerId": 123,
          "from": "eastern_australia",
          "to": "western_australia",
          "armies": 3
        },
      }
      ..expectation = (MoveArmy event, MoveArmy output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.from, equals(event.from));
        expect(output.to, equals(event.to));
        expect(output.armies, equals(event.armies));
      },

  "EndTurn": new SerializableTest()
      ..event = (new EndTurn()..playerId = 123)
      ..json = {
        "event": "EndTurn",
        "data": {
          "playerId": 123,
        },
      }
      ..expectation = (EndTurn event, EndTurn output) {
        expect(output.playerId, equals(event.playerId));
      },

  "Welcome": new SerializableTest()
      ..event = (new Welcome()..playerId = 123)
      ..json = {
        "event": "Welcome",
        "data": {
          "playerId": 123,
        },
      }
      ..expectation = (Welcome event, Welcome output) {
        expect(output.playerId, equals(event.playerId));
      },

  "PlayerJoined": new SerializableTest()
      ..event = (new PlayerJoined()
          ..playerId = 123
          ..name = "John Lennon"
          ..avatar = "kadhafi.png")
      ..json = {
        "event": "PlayerJoined",
        "data": {
          "playerId": 123,
          "name": "John Lennon",
          "avatar": "kadhafi.png",
        },
      }
      ..expectation = (PlayerJoined event, PlayerJoined output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.name, equals(event.name));
        expect(output.avatar, equals(event.avatar));
      },

  "GameStarted": new SerializableTest()
      ..event = (new GameStarted()
          ..armies = 25
          ..playersOrder = [4, 2, 1, 3])
      ..json = {
        "event": "GameStarted",
        "data": {
          "armies": 25,
          "playersOrder": [4, 2, 1, 3]
        },
      }
      ..expectation = (GameStarted event, GameStarted output) {
        expect(output.armies, equals(event.armies));
        expect(output.playersOrder, equals(event.playersOrder));
      },

  "ArmyPlaced": new SerializableTest()
      ..event = (new ArmyPlaced()
          ..playerId = 123
          ..country = "eastern_australia")
      ..json = {
        "event": "ArmyPlaced",
        "data": {
          "playerId": 123,
          "country": "eastern_australia"
        },
      }
      ..expectation = (ArmyPlaced event, ArmyPlaced output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.country, equals(event.country));
      },

  "NextPlayer": new SerializableTest()
      ..event = (new NextPlayer()
          ..playerId = 2
          ..reinforcement = 8)
      ..json = {
        "event": "NextPlayer",
        "data": {
          "playerId": 2,
          "reinforcement": 8
        },
      }
      ..expectation = (NextPlayer event, NextPlayer output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.reinforcement, equals(event.reinforcement));
      },

  "SetupEnded": new SerializableTest()
      ..event = new SetupEnded()
      ..json = {
        "event": "SetupEnded",
        "data": {},
      }
      ..expectation = (SetupEnded event, SetupEnded output) {
      },

  "NextStep": new SerializableTest()
      ..event = new NextStep()
      ..json = {
        "event": "NextStep",
        "data": {},
      }
      ..expectation = (NextStep event, NextStep output) {
      },

  "BattleEnded": new SerializableTest()
      ..event = (new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 3
              ..dices = [3, 2, 1]
              ..country = "eastern_australia"
              ..remainingArmies = 2)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [6, 5]
              ..country = "western_australia"
              ..remainingArmies = 1)
          ..conquered = true)
      ..json = {
        "event": "BattleEnded",
        "data": {
          "attacker": {
            "playerId": 3,
            "dices": [3, 2, 1],
            "country": "eastern_australia",
            "remainingArmies": 2
          },
          "defender": {
            "playerId": 2,
            "dices": [6, 5],
            "country": "western_australia",
            "remainingArmies": 1
          },
          "conquered": true
        },
      }
      ..expectation = (BattleEnded event, BattleEnded output) {
        expect(output.attacker.playerId, equals(event.attacker.playerId));
        expect(output.attacker.dices, equals(event.attacker.dices));
        expect(output.attacker.country, equals(event.attacker.country));
        expect(output.attacker.remainingArmies, equals(
            event.attacker.remainingArmies));
        expect(output.defender.playerId, equals(event.defender.playerId));
        expect(output.defender.dices, equals(event.defender.dices));
        expect(output.defender.country, equals(event.defender.country));
        expect(output.defender.remainingArmies, equals(
            event.defender.remainingArmies));
      },

  "ArmyMoved": new SerializableTest()
      ..event = (new ArmyMoved()
          ..playerId = 123
          ..from = "eastern_australia"
          ..to = "western_australia"
          ..armies = 3)
      ..json = {
        "event": "ArmyMoved",
        "data": {
          "playerId": 123,
          "from": "eastern_australia",
          "to": "western_australia",
          "armies": 3
        },
      }
      ..expectation = (ArmyMoved event, ArmyMoved output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.from, equals(event.from));
        expect(output.to, equals(event.to));
        expect(output.armies, equals(event.armies));
      },

};

main() {
  events.forEach((name, test) => group('$name should be', test.run));

  test('Empty event should not be deserialized', () {
    // WHEN
    var output = EVENT.decode({});

    // THEN
    expect(output, isNull);
  });

  test('Unknown event should not be deserialized', () {
    // WHEN
    var output = EVENT.decode({
      "event": "UnknownEvent"
    });

    // THEN
    expect(output, isNull);
  });

  test('Event without data should not be deserialized', () {
    // WHEN
    var output = EVENT.decode({
      "event": "StartGame"
    });

    // THEN
    expect(output, isNull);
  });
}

class SerializableTest {
  var event;
  var json;
  var expectation;

  run() {
    test('serializable', () {
      // WHEN
      var output = EVENT.encode(event);

      // THEN
      expect(output, equals(json));
    });

    test('deserializable', () {
      // WHEN
      var output = EVENT.decode(json);

      // THEN
      expect(output.runtimeType, equals(event.runtimeType), reason:
          "Type are different");
      expectation(event, output);
    });
  }
}
