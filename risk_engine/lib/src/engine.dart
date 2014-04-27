part of risk_engine.server;

bool autoSetup = new String.fromEnvironment('autoSetup', defaultValue: 'true')
    == 'true';

class EngineException {
  final message;
  EngineException(this.message);
  String toString() => "EngineException: $message";
}

class RiskGameEngine {
  final RiskGameState game;
  final StreamController outputStream;
  final List<EngineEvent> history = [];

  final Hazard hazard;
  final Function exceptionHandler;

  BattleEnded lastBattle;

  RiskGameEngine(this.outputStream, this.game, {Hazard
      hazard, this.exceptionHandler: print}): hazard = hazard != null ? hazard :
      new Hazard();

  void handle(PlayerEvent event) {
    try {
      if (event is JoinGame) {
        onJoinGame(event);
      } else if (event is StartGame) {
        onStartGame(event);
      } else if (event is PlaceArmy) {
        onPlaceArmy(event);
      } else if (event is Attack) {
        onAttack(event);
      } else if (event is EndAttack) {
        onEndAttack(event);
      } else if (event is MoveArmy) {
        onMove(event);
      } else if (event is EndTurn) {
        onEndTurn(event);
      }
    } catch (e) {
      exceptionHandler(e);
    }
  }

  void onJoinGame(JoinGame event) {
    // Check if the player has already joined the game
    checkPlayerExists(event.playerId, notExist: true);
    // Checks if it the game is not started.
    checkGameNotStarted();

    _publish(new PlayerJoined()
        ..playerId = event.playerId
        ..name = event.name
        ..avatar = event.avatar
        ..color = event.color);

    if (game.players.length == RiskGameState.PLAYERS_MAX) {
      startGame();
    }
  }

  void onStartGame(StartGame event) {
    // Only the first connected player can start the game
    // checkFirstPlayer(event.playerId);
    // Checks if it the game is already started.
    checkGameNotStarted();

    if (game.players.length >= RiskGameState.PLAYERS_MIN) {
      startGame();
    }
  }

  void startGame() {
    _publish(new GameStarted()
        ..armies = RiskGameState.START_ARMIES[game.players.length]
        ..playersOrder = hazard.giveOrders(game.players.keys));

    // add one army on every country
    final groupsOfCountries = hazard.split(game.allCountryIds, game.players.length);
    final countries = {};
    int i = 0;
    game.players.keys.forEach((playerId) {
      groupsOfCountries[i++].forEach((c) => _publish(new ArmyPlaced()
          ..playerId = playerId
          ..country = c));
    });

    // add all armies randomly
    if (autoSetup) {
      game.players.values.forEach((playerState) {
        final myCountries = game.countries.values.where((cs) => cs.playerId ==
            playerState.playerId).map((cs) => cs.countryId).toList();
        while (playerState.reinforcement > 0) {
          final country = (myCountries..shuffle()).first;
          _publish(new ArmyPlaced()
              ..playerId = playerState.playerId
              ..country = country);
        }
      });
      _publish(new SetupEnded());
    }

    // next
    nextPlayer();
  }

  void onPlaceArmy(PlaceArmy event) {
    // if another player tries to play
    checkActivePlayer(event.playerId);
    // Check if player as not enough armies
    checkPlayerHasReinforcement(event.playerId);
    // Check if country is owned by another player
    checkCountryOwner(event.country, event.playerId);

    _publish(new ArmyPlaced()
        ..playerId = event.playerId
        ..country = event.country);

    if (game.setupPhase) {
      if (game.players.values.every((ps) => ps.reinforcement == 0)) {
        _publish(new SetupEnded());
      }
      nextPlayer();
    } else if (game.players[event.playerId].reinforcement == 0) {
      _publish(new NextStep());
    }
  }

  void onAttack(Attack event) {
    // if another player tries to play
    checkActivePlayer(event.playerId);
    // Armies should be between 1 and 3 and attacker must have enough armies in the from country
    checkArmiesNumber(event.armies, min: 1, max: 3, countryId: event.from);
    // Check if from country is owned by the player
    checkCountryOwner(event.from, event.playerId);
    // Check if target country is owned by another player
    checkCountryOwner(event.to, event.playerId, notOwned: true);
    // The attacked country must be in the neighbourhood
    checkCountryNeighbourhood(event.from, event.to);

    var defenderId = game.countries[event.to].playerId;

    var attacker = new BattleOpponentResult()
        ..playerId = event.playerId
        ..dices = hazard.rollDices(event.armies)
        ..country = event.from;
    var defender = new BattleOpponentResult()
        ..playerId = defenderId
        ..dices = hazard.rollDices(min(2, game.countries[event.to].armies))
        ..country = event.to;

    var attackerLoss = game.computeAttackerLoss(attacker.dices, defender.dices);
    var defenderLoss = defender.dices.length - attackerLoss;

    attacker.remainingArmies = game.countries[attacker.country].armies -
        attackerLoss;
    defender.remainingArmies = game.countries[defender.country].armies -
        defenderLoss;

    lastBattle = new BattleEnded()
        ..attacker = attacker
        ..defender = defender
        ..conquered = defender.remainingArmies == 0;

    _publish(lastBattle);
  }

  void onMove(MoveArmy event) {
    // if another player tries to play
    checkActivePlayer(event.playerId);
    // Armies should be at least 1 and it must have enough armies in the from country
    checkArmiesNumber(event.armies, min: 1, countryId: event.from, action: 'move');
    // Check if from country is owned by the player
    checkCountryOwner(event.from, event.playerId);
    // Check if target country is owned by the player
    checkCountryOwner(event.to, event.playerId);
    // The attacked country must be in the neighbourhood
    checkCountryNeighbourhood(event.from, event.to);
    if (game.turnStep == RiskGameState.TURN_STEP_ATTACK) {
      // Countries must be the same as last attack
      checkLastAttackCountries(event.from, event.to);
    }

    _publish(new ArmyMoved()
        ..playerId = event.playerId
        ..from = event.from
        ..to = event.to
        ..armies = event.armies);
    lastBattle = null;

    if (game.turnStep == RiskGameState.TURN_STEP_FORTIFICATION) {
      nextPlayer();
    }
  }

  void onEndAttack(EndAttack event) {
    // if another player tries to play
    checkActivePlayer(event.playerId);

    // TODO: check current step

    _publish(new NextStep());
  }

  void onEndTurn(EndTurn event) {
    // if another player tries to play
    checkActivePlayer(event.playerId);

    // TODO: check current step

    nextPlayer();
  }

  void nextPlayer() {
    var orders = game.playersOrder;
    int nextPlayerIndex = game.activePlayerId == null ? 0 : orders.indexOf(
        game.activePlayerId) + 1;
    int nextPlayerId = orders[nextPlayerIndex % orders.length];
    int reinforcement = game.setupPhase ?
        game.players[nextPlayerId].reinforcement : game.computeReinforcement(
        nextPlayerId);

    _publish(new NextPlayer()
        ..playerId = nextPlayerId
        ..reinforcement = reinforcement);
  }

  _publish(EngineEvent event) {
    game.update(event);
    history.add(event);
    outputStream.add(event);
  }

  /**
   * Checks if the player exists.
   * If [notExist] is [true] Checks if the player has already joined the game.
   */
  checkPlayerExists(int playerId, {notExist: false}) {
    if (game.players.containsKey(playerId) == notExist) throw
        new EngineException(
        "Player #$playerId is ${notExist ? 'already' : 'not'} registered");
  }

  /// Checks if another player tries to play.
  checkActivePlayer(int playerId) {
    checkPlayerExists(playerId);
    if (playerId != game.activePlayerId) throw new EngineException(
        "Player #$playerId is not the active player");
  }

  /// Checks if it is the first connected player.
  checkFirstPlayer(int playerId) {
    checkPlayerExists(playerId);
    if (playerId != game.players.keys.first) throw new EngineException(
        "Player #$playerId is not the first connected player");
  }

  /// Checks if it the game is already started.
  checkGameNotStarted() {
    if (game.started) throw new EngineException("Game is already started");
  }

  /// Checks if the player has reinforcement.
  checkPlayerHasReinforcement(int playerId) {
    checkPlayerExists(playerId);
    if (game.players[playerId].reinforcement == 0) throw new EngineException(
        "Player #$playerId hasn't reinforcement armies");
  }

  /// Checks if the country exists.
  checkCountryExists(String countryId) {
    if (!game.allCountryIds.contains(countryId)) throw new EngineException(
        "Country #$countryId doesn't exist");
  }

  /// Checks if countries are neighbours.
  checkCountryNeighbourhood(String countryAId, String countryBId) {
    checkCountryExists(countryAId);
    checkCountryExists(countryBId);
    if (!game.countryNeighbours(countryAId).contains(countryBId)) throw
        new EngineException(
        "Country #$countryAId is not in neighbourhood of #$countryBId");
  }

  /**
   * Checks if the [countryId] is owned by the [playerId] or neutral.
   * If [notOwned] is [true] Checks if the [countryId] is not owned by the [playerId].
   */
  checkCountryOwner(String countryId, int playerId, {bool notOwned: false}) {
    checkCountryExists(countryId);
    var countryState = game.countries[countryId];
    if ((countryState == null || countryState.playerId == playerId) == notOwned)
        throw new EngineException(
        "Country #$countryId is ${notOwned ? '' : 'not '}owned by player #$playerId");
  }

  /// Checks the number of armies bounds
  checkArmiesNumber(int armies, {int min, int max: null, String countryId, String action:
      'attack'}) {
    if (min != null && armies < min) throw new EngineException(
        "Can't $action with less than $min armies");
    if (max != null && armies > max) throw new EngineException(
        "Can't $action with more than $max armies");

    if(countryId != null) {
      /// Checks if there is enough armies in country to attack or to move
      checkCountryExists(countryId);
      if (game.countries[countryId].armies - armies < 1) throw
          new EngineException("There is not enough armies in country #${countryId}");
    }
  }

  /// Checks if countries are the same as the last attack
  checkLastAttackCountries(String from, String to) {
    if (lastBattle == null) throw new EngineException(
        "Engaged armies are already moved");
    if (from != lastBattle.attacker.country || to !=
        lastBattle.defender.country) throw new EngineException(
        "Countries doesn't match with the last battle");
  }
}

/// Hazard of the game
class Hazard {
  final Random _random = new Random();

  /// Shuffles the [players] order
  List<int> giveOrders(Iterable<int> players) => players.toList()..shuffle(
      _random);

  /// Rolls [n] dices and returns the result in descending order
  List<int> rollDices(int n) => (new List<int>.generate(n, (_) =>
      _random.nextInt(6) + 1)..sort()).reversed.toList();

  /// Split a list into [n] part with random elements
  // TODO test
  List<List> split(Iterable elements, int n) {
    final l = elements.toList()..shuffle(_random);
    final result = new List.generate(n, (i) => []);
    for (int i = 0; i < l.length; i++) {
      result[i % n].add(l[i]);
    }
    return result;
  }
}
