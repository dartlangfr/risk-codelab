library risk.game.test;

import 'package:unittest/unittest.dart';
import 'package:risk_engine/server.dart';
import 'package:risk/risk.dart';
import 'utils.dart';

main() {
  group('Game countries', testGameCountries);
  group('Dices attack computation', testDicesAttackComputation);
  group('Reinforcement computation', testReinforcementComputation);
  group('RiskGame.update', testRiskGame);
}

testGameCountries() {
  var game = new RiskGameStateImpl();

  test('allCountryIds should return all country ids', () {
    expect(game.allCountryIds, equals(COUNTRIES.keys));
  });

  COUNTRIES.forEach((countryId, country) {
    test('$countryId should have specified neighbours', () {
      expect(game.countryNeighbours(countryId), equals(country.neighbours));
    });
  });
}

testDicesAttackComputation() {
  var game = new RiskGameStateImpl();
  test('[2] vs [1]', () {
    expect(game.computeAttackerLoss([2], [1]), equals(0));
  });
  test('[2] vs [2,1]', () {
    expect(game.computeAttackerLoss([2], [2, 1]), equals(1));
  });
  test('[2,1] vs [1]', () {
    expect(game.computeAttackerLoss([2, 1], [1]), equals(0));
  });
  test('[1,1] vs [1]', () {
    expect(game.computeAttackerLoss([1, 1], [1]), equals(1));
  });
  test('[1,1,1] vs [1]', () {
    expect(game.computeAttackerLoss([1, 1, 1], [1]), equals(1));
  });
  test('[2,2,1] vs [2,1]', () {
    expect(game.computeAttackerLoss([2, 2, 1], [2, 1]), equals(1));
  });
  test('[2,2,1] vs [1,1]', () {
    expect(game.computeAttackerLoss([2, 2, 1], [1, 1]), equals(0));
  });
  test('[2,2,1] vs [4,3]', () {
    expect(game.computeAttackerLoss([2, 2, 1], [4, 3]), equals(2));
  });
}

testReinforcementComputation() {
  final playerId = 1;
  buildGame(Iterable<String> countries) {
    RiskGameState game = new RiskGameStateImpl();
    countries.forEach((c) => game.countries[c] = new CountryStateImpl(c, playerId:
        playerId, armies: 1));
    return game;
  }

  test('for one country', () {
    var countries = ["eastern_australia"];
    var expected = 3;
    expect(buildGame(countries).computeReinforcement(playerId), equals(expected
        ));
  });

  test('for 4 countries', () {
    var countries = ["eastern_australia", "congo", "egypt", "east_africa"];
    var expected = 3;
    expect(buildGame(countries).computeReinforcement(playerId), equals(expected
        ));
  });

  test('for 13 countries', () {
    var countries = ["eastern_australia", "brazil", "congo", "egypt",
        "east_africa", "alberta", "central_america", "eastern_united_states",
        "greenland", "northwest_territory", "ontario", "quebec",
        "western_united_states"];
    var expected = 4;
    expect(buildGame(countries).computeReinforcement(playerId), equals(expected
        ));
  });

  test('for Australia', () {
    var countries = CONTINENTS.firstWhere((c) => c.id == 'australia').countries;
    // 4 countries + 2
    var expected = 3;
    expect(buildGame(countries).computeReinforcement(playerId), equals(expected
        ));
  });

  test('for North america + 3 other countries', () {
    var countries = ["congo", "egypt", "east_africa"]..addAll(
        CONTINENTS.firstWhere((c) => c.id == 'north_america').countries);
    // 12 countries + Noth america bonus
    var expected = (12 ~/ 3) + (5);
    expect(buildGame(countries).computeReinforcement(playerId), equals(expected
        ));
  });

  test('for All countries and continents', () {
    var countries = COUNTRIES.keys;
    // 42 countries + all continents bonus
    var expected = (42 ~/ 3) + (2 + 5 + 2 + 3 + 5 + 7);
    expect(buildGame(countries).computeReinforcement(playerId), equals(expected
        ));
  });
}

testRiskGame() {
  RiskGameStateImpl game;

  setUp(() {
    game = riskGameReinforcement();
  });

  test('should get countries owned by players', () {
    expect(game.playerCountries(1), unorderedEquals(["western_australia",
        "new_guinea"]));
    expect(game.playerCountries(2), unorderedEquals(["siam", "great_britain",
        "indonesia"]));
    expect(game.playerCountries(42), equals(new Set()));
  });

  test('on PlayerJoined should add a player', () {
    // GIVEN
    game = riskGamePlayerJoining();
    var event = new PlayerJoined()
        ..playerId = 123
        ..name = "John Lennon"
        ..avatar = "kadhafi.png"
        ..color = "red";

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGamePlayerJoining();
    expected.players[123] = new PlayerStateImpl(123, "John Lennon", "kadhafi.png",
        "red");

    expectEquals(game, expected);
  });

  test('on GameStarted should set player orders and player reinforcements', () {
    // GIVEN
    game = riskGamePlayerJoining();
    var event = new GameStarted()
        ..playersOrder = [2, 1, 0]
        ..armies = 42;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGamePlayerJoining();
    expected.started = true;
    expected.setupPhase = true;
    expected.playersOrder = [2, 1, 0];
    expected.players[0].reinforcement = 42;
    expected.players[1].reinforcement = 42;
    expected.players[2].reinforcement = 42;

    expectEquals(game, expected);
  });

  test('on ArmyPlaced should add an army on a neutral country', () {
    // GIVEN
    var event = new ArmyPlaced()
        ..playerId = 0
        ..country = "eastern_australia";

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.countries["eastern_australia"] = new CountryStateImpl(
        "eastern_australia", playerId: 0, armies: 1);
    expected.players[0].reinforcement--;

    expectEquals(game, expected);
  });

  test('on ArmyPlaced should add an army on country owned by the player', () {
    // GIVEN
    var event = new ArmyPlaced()
        ..playerId = 1
        ..country = "western_australia";

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.countries["western_australia"].armies++;
    expected.players[1].reinforcement--;

    expectEquals(game, expected);
  });

  test('on NextPlayer should set the current player and his reinforcement', () {
    // GIVEN
    var event = new NextPlayer()
        ..playerId = 2
        ..reinforcement = 42;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;
    expected.activePlayerId = 2;
    expected.players[2].reinforcement = 42;

    expectEquals(game, expected);
  });

  test('on SetupEnded should set the setupPhase to false', () {
    // GIVEN
    game = riskGameSetuping();
    var event = new SetupEnded();

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameSetuping();
    expected.setupPhase = false;

    expectEquals(game, expected);
  });

  test('on NextStep should set attack when reinforcement', () {
    // GIVEN
    game = riskGameReinforcement();
    game.turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;
    var event = new NextStep();

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.turnStep = RiskGameState.TURN_STEP_ATTACK;

    expectEquals(game, expected);
  });

  test('on NextStep should set step when attack', () {
    // GIVEN
    game = riskGameReinforcement();
    game.turnStep = RiskGameState.TURN_STEP_ATTACK;
    var event = new NextStep();

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.turnStep = RiskGameState.TURN_STEP_FORTIFICATION;

    expectEquals(game, expected);
  });

  test('on NextStep should keep fortification step when already fortification',
      () {
    // GIVEN
    game = riskGameReinforcement();
    game.turnStep = RiskGameState.TURN_STEP_FORTIFICATION;
    var event = new NextStep();

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.turnStep = RiskGameState.TURN_STEP_FORTIFICATION;

    expectEquals(game, expected);
  });

  test('on BattleEnded should set remaining armies in countries', () {
    // GIVEN
    var event = new BattleEnded()
        ..attacker = (new BattleOpponentResult()
            ..playerId = 1
            ..dices = [3, 2, 1]
            ..country = "western_australia"
            ..remainingArmies = 2)
        ..defender = (new BattleOpponentResult()
            ..playerId = 2
            ..dices = [6, 5]
            ..country = "indonesia"
            ..remainingArmies = 1)
        ..conquered = false;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.countries["western_australia"].armies = 2;
    expected.countries["indonesia"].armies = 1;

    expectEquals(game, expected);
  });

  test('on BattleEnded and conquered should set remaining armies in countries',
      () {
    // GIVEN
    var event = new BattleEnded()
        ..attacker = (new BattleOpponentResult()
            ..playerId = 1
            ..dices = [3, 2, 1]
            ..country = "western_australia"
            ..remainingArmies = 4)
        ..defender = (new BattleOpponentResult()
            ..playerId = 2
            ..dices = [1, 1]
            ..country = "siam"
            ..remainingArmies = 0)
        ..conquered = true;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.countries["western_australia"].armies = 4;
    expected.countries["siam"].armies = 0;
    expected.countries["siam"].playerId = 1;

    expectEquals(game, expected);
  });

  test('on ArmyMoved should move armies', () {
    // GIVEN
    var event = new ArmyMoved()
        ..playerId = 1
        ..from = "new_guinea"
        ..to = "western_australia"
        ..armies = 2;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameReinforcement();
    expected.countries["new_guinea"].armies -= 2;
    expected.countries["western_australia"].armies += 2;

    expectEquals(game, expected);
  });
}
