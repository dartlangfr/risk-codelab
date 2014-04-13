library risk.test.utils;

import 'dart:async';
import 'package:morph/morph.dart';
import 'package:unittest/unittest.dart';
import 'package:risk_engine/risk_engine.dart';
import '../lib/risk.dart';

/*
 * Assert equality between [actual] and [expected] by reflection.
 */
void expectEquals(actual, expected, {String reason, FailureHandler
    failureHandler, bool verbose: false}) {
  expect(_MORPH.serialize(actual), equals(_MORPH.serialize(expected)), reason:
      reason, failureHandler: failureHandler, verbose: verbose);
}


/// Build an instance of PlayerState
PlayerStateImpl playerState({playerId: 123, name: "John", avatar:
    "avatar.png", color: "blue", reinforcement: 0}) => new PlayerStateImpl(playerId,
    name, avatar, color, reinforcement: reinforcement);

/// Build an instance of RiskGameState when players are joining and game is not started yet
RiskGameStateImpl riskGamePlayerJoining() => new RiskGameStateImpl()
    ..events = []
    ..players = {
      0: playerState(),
      1: playerState(),
      2: playerState(),
    };

/// Build an instance of RiskGameState when game started and it is setuping
RiskGameStateImpl riskGameSetuping() => new RiskGameStateImpl()
    ..events = []
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

/// Build an instance of RiskGameState when setup is over and one player is reinforcing
RiskGameStateImpl riskGameReinforcement() => riskGameSetuping()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 5),
      2: playerState(reinforcement: 0),
    }
    ..setupPhase = false
    ..turnStep = RiskGameState.TURN_STEP_REINFORCEMENT
    ..activePlayerId = 1;


/// Build an instance of RiskGameState when player is attacking
RiskGameStateImpl riskGameAttacking() => riskGameReinforcement()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 0),
      2: playerState(reinforcement: 0),
    }
    ..turnStep = RiskGameState.TURN_STEP_ATTACK;


/// Build an instance of RiskGameState when player is fortifying
RiskGameStateImpl riskGameFortification() => riskGameAttacking()
    ..turnStep = RiskGameState.TURN_STEP_FORTIFICATION;




// When we try to serialize Observable object, we get an error on serializing `changes` value
final ignoreObservableStreamType = new StreamController.broadcast(sync: true).stream.runtimeType;
final _MORPH = new Morph()..registerTypeAdapter(ignoreObservableStreamType,
    new _ToNullSerializer());

class _ToNullSerializer extends Serializer {
  @override
  serialize(object) => null;
}
