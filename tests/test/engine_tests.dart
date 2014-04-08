library risk.engine.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import 'package:risk_engine/server.dart';
import 'package:risk/risk.dart';
import 'utils.dart';

main() {
  group('RiskGameEngine', testRiskGameEngine);
}

testRiskGameEngine() {
  HazardMock hazard;
  StreamController outputStream;
  RiskGameEngine engine;
  RiskGameStateImpl engineGame() => engine.game;

  rethrowHandler(e) => throw e;

  RiskGameEngine riskGameEngine(RiskGameState game) => new RiskGameEngine(
      outputStream, game, hazard: hazard, exceptionHandler: rethrowHandler);

  setUp(() {
    hazard = new HazardMock();
    outputStream = new StreamController(sync: true);
    engine = riskGameEngine(riskGameReinforcement());
    autoSetup = false;
  });

  eventsList() {
    outputStream.close();
    return outputStream.stream.toList();
  }

  expectEvents(List<EngineEvent> expectedEvents) => eventsList().then((events)
      => expectEquals(events, expectedEvents));


  testEngineErrorCase(EngineErrorCase errorCase, riskGame()) {
    errorCase.setup(engine.game);

    // WHEN
    expect(() => engine.handle(errorCase.event), throwsEngineException(
        errorCase.exceptionPattern));

    // THEN
    var expected = riskGame();
    errorCase.setup(expected);

    expectEquals(engine.game, expected);
    return expectEvents([]);
  }

  group('on JoinGame', () {
    setUp(() => engine = riskGameEngine(riskGamePlayerJoining()));

    test('should add a player', () {
      // GIVEN
      var event = new JoinGame()
          ..playerId = 123
          ..name = "John Lennon"
          ..avatar = "kadhafi.png"
          ..color = "red";

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.players[123] = new PlayerStateImpl(123, "John Lennon", "kadhafi.png",
          "red");

      expectEquals(engine.game, expected);
      return expectEvents([new PlayerJoined()
            ..playerId = 123
            ..name = "John Lennon"
            ..color = "red"
            ..avatar = "kadhafi.png"]);
    });

    test('should NOT add an existing player', () {
      // GIVEN
      var event = new JoinGame()
          ..playerId = 1
          ..name = "John Lennon"
          ..color = "red"
          ..avatar = "kadhafi.png";
      var exceptionPattern = "is already registered";

      // WHEN
      expect(() => engine.handle(event), throwsEngineException(exceptionPattern)
          );

      // THEN
      var expected = riskGamePlayerJoining();

      expectEquals(engine.game, expected);
      return expectEvents([]);
    });
  });

  group('on StarGame', () {
    setUp(() => engine = riskGameEngine(riskGamePlayerJoining()));

    test('should start game', () {
      // GIVEN
      var event = new StartGame()..playerId = 0;
      engineGame().activePlayerId = null;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.started = true;
      expected.setupPhase = true;
      expected.turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;
      expected.playersOrder = [2, 1, 0];
      expected.activePlayerId = 2;
      expected.players[0].reinforcement = 35;
      expected.players[1].reinforcement = 35;
      expected.players[2].reinforcement = 35;

      expectEquals(engine.game, expected);
      return expectEvents([new GameStarted()
            ..armies = 35
            ..playersOrder = [2, 1, 0], new NextPlayer()
            ..playerId = 2
            ..reinforcement = 35]);
    });

    skip_test('should NOT start game when it is not the master player', () {
      // GIVEN
      var event = new StartGame()..playerId = 2;

      // WHEN
      expect(() => engine.handle(event), throwsEngineException(
          "not the first connected player"));

      // THEN
      var expected = riskGamePlayerJoining();

      expectEquals(engine.game, expected);
      return expectEvents([]);
    });

    test('should NOT start game when there is not enough player', () {
      // GIVEN
      var event = new StartGame()..playerId = 0;
      engineGame().players = {
        0: playerState()
      };

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.players = {
        0: playerState()
      };

      expectEquals(engine.game, expected);
      return expectEvents([]);
    });

    test('should NOT start game if the game is already started', () {
      // GIVEN
      var event = new StartGame()..playerId = 0;
      engineGame().started = true;

      // WHEN
      expect(() => engine.handle(event), throwsEngineException(
          "Game is already started"));

      // THEN
      var expected = riskGamePlayerJoining();
      expected.started = true;

      expectEquals(engine.game, expected);
      return expectEvents([]);
    });
  });

  group('on ArmyPlaced', () {
    group('when setuping', () {
      setUp(() => engine = riskGameEngine(riskGameSetuping()));

      test('should add an army and next player', () {
        // GIVEN
        engineGame().activePlayerId = 1;
        var event = new PlaceArmy()
            ..playerId = 1
            ..country = "eastern_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameSetuping();
        expected.countries["eastern_australia"] = new CountryStateImpl(
            "eastern_australia", playerId: 1, armies: 1);
        expected.players[1].reinforcement--;

        expected.activePlayerId = 2;
        expected.turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 1
              ..country = "eastern_australia", new NextPlayer()
              ..playerId = 2
              ..reinforcement = 10]);
      });

      test('should add an army and end setup when all armies are placed', () {
        // GIVEN
        engineGame().players = {
          0: playerState(reinforcement: 0),
          1: playerState(reinforcement: 0),
          2: playerState(reinforcement: 1),
        };
        var event = new PlaceArmy()
            ..playerId = 2
            ..country = "eastern_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameSetuping();
        expected.countries["eastern_australia"] = new CountryStateImpl(
            "eastern_australia", playerId: 2, armies: 1);

        expected.setupPhase = false;
        expected.activePlayerId = 0;
        expected.turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;

        expected.players = {
          0: playerState(reinforcement: 3),
          1: playerState(reinforcement: 0),
          2: playerState(reinforcement: 0),
        };

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 2
              ..country = "eastern_australia", new SetupEnded(), new NextPlayer(
                  )
              ..playerId = 0
              ..reinforcement = 3]);
      });
    });

    group('in player turn', () {
      test('should add an army on a neutral country', () {
        // GIVEN
        var event = new PlaceArmy()
            ..playerId = 1
            ..country = "eastern_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameReinforcement();
        expected.countries["eastern_australia"] = new CountryStateImpl(
            "eastern_australia", playerId: 1, armies: 1);
        expected.players[1].reinforcement--;

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 1
              ..country = "eastern_australia"]);
      });

      test('should add an army on country owned by the player', () {
        // GIVEN
        var event = new PlaceArmy()
            ..playerId = 1
            ..country = "western_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameReinforcement();
        expected.countries["western_australia"].armies++;
        expected.players[1].reinforcement--;

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 1
              ..country = "western_australia"]);
      });
    });

    test('should add an army and next step', () {
      // GIVEN
      engineGame()..players[1].reinforcement = 1;
      var event = new PlaceArmy()
          ..playerId = 1
          ..country = "eastern_australia";

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameReinforcement();
      expected.countries["eastern_australia"] = new CountryStateImpl(
          "eastern_australia", playerId: 1, armies: 1);
      expected.players[1].reinforcement = 0;

      expected.turnStep = RiskGameState.TURN_STEP_ATTACK;

      expectEquals(engine.game, expected);
      return expectEvents([new ArmyPlaced()
            ..playerId = 1
            ..country = "eastern_australia", new NextStep()]);
    });

    var errorCases = {
      'on country owned by another player': new EngineErrorCase()
          ..event = (new PlaceArmy()
              ..playerId = 1
              ..country = "indonesia")
          ..exceptionPattern = "is not owned by player",
      'if the player has not enough reinforcement armies': new EngineErrorCase()
          ..setup = (RiskGameStateImpl game) {
            game.players[1].reinforcement = 0;
          }
          ..event = (new PlaceArmy()
              ..playerId = 1
              ..country = "western_australia")
          ..exceptionPattern = "hasn't reinforcement armies",
    };

    errorCases.forEach((key, errorCase) {
      test('should NOT add an army $key', () => testEngineErrorCase(errorCase,
          riskGameReinforcement));
    });
  });

  group('on Attack', () {
    test('should result in a BattleEnd', () {
      // GIVEN
      var event = new Attack()
          ..playerId = 1
          ..from = "western_australia"
          ..to = "indonesia"
          ..armies = 2;
      hazard.when(callsTo('rollDices')).thenReturn([6, 1]).thenReturn([2, 1]);

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameReinforcement();
      expected.countries["western_australia"].armies -= 1;
      expected.countries["indonesia"].armies -= 1;

      var expectedEvent = new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 1
              ..dices = [6, 1]
              ..country = "western_australia"
              ..remainingArmies = 3)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [2, 1]
              ..country = "indonesia"
              ..remainingArmies = 1)
          ..conquered = false;

      expectEquals(engine.game, expected);
      return expectEvents([expectedEvent]);
    });

    test('should result in a BattleEnd with country conquered', () {
      // GIVEN
      var event = new Attack()
          ..playerId = 1
          ..from = "western_australia"
          ..to = "indonesia"
          ..armies = 3;
      hazard.when(callsTo('rollDices')).thenReturn([6, 3, 1]).thenReturn([2, 1]
          );

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameReinforcement();
      expected.countries["indonesia"].armies -= 2;
      expected.countries["indonesia"].playerId = 1;

      var expectedEvent = new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 1
              ..dices = [6, 3, 1]
              ..country = "western_australia"
              ..remainingArmies = 4)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [2, 1]
              ..country = "indonesia"
              ..remainingArmies = 0)
          ..conquered = true;

      expectEquals(engine.game, expected);
      return expectEvents([expectedEvent]);
    });

    // Working event
    workingAttack() => new Attack()
        ..playerId = 1
        ..from = "western_australia"
        ..to = "indonesia"
        ..armies = 3;

    var errorCases = {
      "when it\'s not the active player": new EngineErrorCase()
          ..event = (workingAttack()..playerId = 2)
          ..exceptionPattern = "is not the active player",
      "when 0 armies are sent": new EngineErrorCase()
          ..event = (workingAttack()..armies = 0)
          ..exceptionPattern = "Can't attack with less than",
      "when 4 armies are sent": new EngineErrorCase()
          ..event = (workingAttack()..armies = 4)
          ..exceptionPattern = "Can't attack with more than",
      "when the from country is not owned by the player": new EngineErrorCase()
          ..event = (workingAttack()..from = "siam")
          ..exceptionPattern = "is not owned by player",
      "when the to country is owned by the player": new EngineErrorCase()
          ..event = (workingAttack()..to = "new_guinea")
          ..exceptionPattern = "is owned by player",
      "when the attacked country is not in the neighbourhood":
          new EngineErrorCase()
          ..event = (workingAttack()..to = "great_britain")
          ..exceptionPattern = "is not in neighbourhood",
      "when the player has not enough armies in the country":
          new EngineErrorCase()
          ..event = (workingAttack()..from = "new_guinea")
          ..exceptionPattern = "not enough armies in country",
      "when from country doesn't exist": new EngineErrorCase()
          ..event = (workingAttack()..from = "dart")
          ..exceptionPattern = "doesn't exist",
      "when to country doesn't exist": new EngineErrorCase()
          ..event = (workingAttack()..to = "dart")
          ..exceptionPattern = "doesn't exist",
    };

    errorCases.forEach((key, errorCase) {
      test('should NOT result in a BattleEnd $key', () => testEngineErrorCase(
          errorCase, riskGameReinforcement));
    });
  });


  workingMove() => new MoveArmy()
      ..playerId = 1
      ..from = "western_australia"
      ..to = "new_guinea"
      ..armies = 2;

  group('on Attack Move', () {
    setUp(() => engine = riskGameEngine(riskGameAttacking()));

    test('should move armies', () {
      // GIVEN
      var event = workingMove();
      engineGame().turnStep = RiskGameState.TURN_STEP_ATTACK;
      engine.lastBattle = new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 1
              ..dices = [6, 3, 1]
              ..country = "western_australia"
              ..remainingArmies = 4)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [2, 1]
              ..country = "new_guinea"
              ..remainingArmies = 0)
          ..conquered = true;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameAttacking();
      expected.countries["western_australia"].armies -= 2;
      expected.countries["new_guinea"].armies += 2;

      var expectedEvent = new ArmyMoved()
          ..playerId = 1
          ..from = "western_australia"
          ..to = "new_guinea"
          ..armies = 2;

      expectEquals(engine.game, expected);
      return expectEvents([expectedEvent]);
    });

    test("can't move armies after a battle if not the same countries", () {
      // GIVEN
      var event = new MoveArmy()
          ..playerId = 1
          ..from = "western_australia"
          ..to = "new_guinea"
          ..armies = 2;
      engineGame().turnStep = RiskGameState.TURN_STEP_ATTACK;
      engine.lastBattle = new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 1
              ..dices = [6, 3, 1]
              ..country = "western_australia"
              ..remainingArmies = 4)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [2, 1]
              ..country = "indonesia"
              ..remainingArmies = 0)
          ..conquered = true;
      var exceptionPattern = "Countries doesn't match";

      // WHEN
      expect(() => engine.handle(event), throwsEngineException(exceptionPattern)
          );

      // THEN
      var expected = riskGameAttacking();

      expectEquals(engine.game, expected);
      return expectEvents([]);
    });

    var errorCases = {
      "when it\'s not the active player": new EngineErrorCase()
          ..event = (workingMove()..playerId = 2)
          ..exceptionPattern = "is not the active player",
      "when 0 armies are sent": new EngineErrorCase()
          ..event = (workingMove()..armies = 0)
          ..exceptionPattern = "Can't move with less than",
      "when the from country is not owned by the player": new EngineErrorCase()
          ..event = (workingMove()..from = "siam")
          ..exceptionPattern = "is not owned by player",
      "when the to country is owned by the player": new EngineErrorCase()
          ..event = (workingMove()..to = "siam")
          ..exceptionPattern = "is not owned by player",
      "when the attacked country is not in the neighbourhood":
          new EngineErrorCase()
          ..event = (workingMove()..to = "greenland")
          ..exceptionPattern = "is not in neighbourhood",
      "when the player has not enough armies in the country":
          new EngineErrorCase()
          ..event = (workingMove()..armies = 4)
          ..exceptionPattern = "not enough armies in country",
      "when from country doesn't exist": new EngineErrorCase()
          ..event = (workingMove()..from = "dart")
          ..exceptionPattern = "doesn't exist",
      "when to country doesn't exist": new EngineErrorCase()
          ..event = (workingMove()..to = "dart")
          ..exceptionPattern = "doesn't exist",
    };

    errorCases.forEach((key, errorCase) {
      test('should NOT result in a BattleEnd $key', () => testEngineErrorCase(
          errorCase, riskGameAttacking));
    });

  });

  group('on Fortication Move', () {
    setUp(() => engine = riskGameEngine(riskGameFortification()));

    test('should move armies when fortifying', () {
      // GIVEN
      var event = workingMove();

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameFortification();
      expected.countries["western_australia"].armies -= 2;
      expected.countries["new_guinea"].armies += 2;

      expected.activePlayerId = 2;
      expected.players[2].reinforcement = 3;
      expected.turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;

      var expectedEvents = [new ArmyMoved()
            ..playerId = 1
            ..from = "western_australia"
            ..to = "new_guinea"
            ..armies = 2, new NextPlayer()
            ..playerId = 2
            ..reinforcement = 3];

      expectEquals(engine.game, expected);
      return expectEvents(expectedEvents);
    });

    var errorCases = {
      "when it\'s not the active player": new EngineErrorCase()
          ..event = (workingMove()..playerId = 2)
          ..exceptionPattern = "is not the active player",
      "when 0 armies are sent": new EngineErrorCase()
          ..event = (workingMove()..armies = 0)
          ..exceptionPattern = "Can't move with less than",
      "when the from country is not owned by the player": new EngineErrorCase()
          ..event = (workingMove()..from = "siam")
          ..exceptionPattern = "is not owned by player",
      "when the to country is owned by the player": new EngineErrorCase()
          ..event = (workingMove()..to = "siam")
          ..exceptionPattern = "is not owned by player",
      "when the attacked country is not in the neighbourhood":
          new EngineErrorCase()
          ..event = (workingMove()..to = "greenland")
          ..exceptionPattern = "is not in neighbourhood",
      "when the player has not enough armies in the country":
          new EngineErrorCase()
          ..event = (workingMove()..armies = 4)
          ..exceptionPattern = "not enough armies in country",
      "when from country doesn't exist": new EngineErrorCase()
          ..event = (workingMove()..from = "dart")
          ..exceptionPattern = "doesn't exist",
      "when to country doesn't exist": new EngineErrorCase()
          ..event = (workingMove()..to = "dart")
          ..exceptionPattern = "doesn't exist",
    };

    errorCases.forEach((key, errorCase) {
      test('should NOT result in a BattleEnd $key', () => testEngineErrorCase(
          errorCase, riskGameFortification));
    });
  });
}

class HazardMock extends Mock implements Hazard {
  List<int> giveOrders(Iterable<int> players) => players.toList(
      ).reversed.toList();

  // TODO: tests with data
  List<List> split(Iterable elements, int n) => new List.generate(n, (_) => []);
}

class EngineErrorCase {
  PlayerEvent event;
  String exceptionPattern;
  var setup = (RiskGameStateImpl game) {};
}

throwsEngineException(String pattern) => throwsA(predicate((ex) => ex is
    EngineException && new RegExp(pattern).hasMatch(ex.message),
    'EngineException with message containing "$pattern"'));
