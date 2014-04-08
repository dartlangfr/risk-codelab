library risk.test.utils;

import 'package:morph/morph.dart';
import 'package:unittest/unittest.dart';
import 'package:risk_engine/server.dart';
import 'package:risk/risk.dart';

/*
 * Assert equality between [actual] and [expected] by reflection.
 */
void expectEquals(actual, expected, {String reason, FailureHandler
    failureHandler, bool verbose: false}) {
  expect(_MORPH.serialize(actual), equals(_MORPH.serialize(expected)), reason:
      reason, failureHandler: failureHandler, verbose: verbose);
}

// TODO: comments
PlayerStateImpl playerState({playerId: 123, name: "John", avatar:
    "avatar.png", color: "blue", reinforcement: 0}) => new PlayerStateImpl(playerId,
    name, avatar, color, reinforcement: reinforcement);

RiskGameStateImpl riskGamePlayerJoining() => new RiskGameStateImpl()..players = {
      0: playerState(),
      1: playerState(),
      2: playerState(),
    };

RiskGameStateImpl riskGameSetuping() => new RiskGameStateImpl()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 1),
      2: playerState(reinforcement: 10),
    }
    ..countries = {
      "western_australia": new CountryStateImpl("western_australia", playerId: 1,
          armies: 4),
      "new_guinea": new CountryStateImpl("new_guinea", playerId: 1, armies: 3),
      "indonesia": new CountryStateImpl("indonesia", playerId: 2, armies: 2),
      "siam": new CountryStateImpl("siam", playerId: 2, armies: 4),
      "great_britain": new CountryStateImpl("great_britain", playerId: 2, armies: 4
          ),
    }
    ..started = true
    ..setupPhase = true
    ..activePlayerId = 2
    ..playersOrder = [1, 2, 0];

RiskGameStateImpl riskGameReinforcement() => riskGameSetuping()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 5),
      2: playerState(reinforcement: 0),
    }
    ..setupPhase = false
    ..turnStep = RiskGameState.TURN_STEP_REINFORCEMENT
    ..activePlayerId = 1;


RiskGameStateImpl riskGameAttacking() => riskGameReinforcement()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 0),
      2: playerState(reinforcement: 0),
    }
    ..turnStep = RiskGameState.TURN_STEP_ATTACK;


RiskGameStateImpl riskGameFortification() => riskGameAttacking()
    ..turnStep = RiskGameState.TURN_STEP_FORTIFICATION;

// When we try to serialize Observable object, we get an error on serializing `changes` value
final ignoreObservableStreamType = new RiskGameStateImpl().changes.runtimeType;
final _MORPH = new Morph()..registerTypeAdapter(ignoreObservableStreamType,
    new _ToNullSerializer());

class _ToNullSerializer extends Serializer {
  @override
  serialize(object) => null;
}
