part of risk;

/// Stores the state of a country.
class CountryStateImpl implements CountryState {
  /// The countryId for this CountryState.
  final String countryId;
  /// The playerId who owns this country.
  int playerId;
  /// The number of armies in this country.
  int armies;
  CountryStateImpl(this.countryId, {this.playerId, this.armies: 0});
}

/// Stores the state of a player.
class PlayerStateImpl implements PlayerState {
  /// The playerId for this CountryState.
  final int playerId;
  /// The player's name.
  String name;
  /// The player's avatar.
  String avatar;
  /// The player's color.
  String color;
  /// The number of available armies for the player.
  int reinforcement;
  /// True if the player lost the game.
  bool dead;

  PlayerStateImpl(this.playerId, this.name, this.avatar, this.color, {this.reinforcement: 0, this.dead: false});
}

/// Stores the Risk game state.
class RiskGameStateImpl implements RiskGameState {
  /// Returns the countryId / country state map.
  Map<String, CountryStateImpl> countries = {};
  /// Returns the playerId / player state map.
  Map<int, PlayerStateImpl> players = {};
  /// Returns the players order.
  List<int> playersOrder = [];
  /// Returns the player who is playing.
  int activePlayerId;

  /// True if the game is started.
  bool started = false;
  /// True if the game is setuping player countries.
  bool setupPhase = false;
  /// Return the turn step of the active player (REINFORCEMENT, ATTACK, FORTIFICATION).
  String turnStep;

  /// Returns the history of all events
  List<EngineEvent> events = [];

  /// Returns all possible countryIds
  List<String> get allCountryIds => COUNTRY_BY_ID.keys.toList();

  /// Returns neighbours ids for the given [countryId].
  List<String> countryNeighbours(String countryId) => COUNTRY_BY_ID[countryId].neighbours;

  /// Computes attacker loss comparing rolled [attacks] and [defends] dices.
  /// This method assumes that [attacks] and [defends] are sorted in a descending order
  int computeAttackerLoss(List<int> attacks, List<int> defends) {
    int result = 0;
    for (int i = 0; i < min(attacks.length, defends.length); i++) {
      if (attacks[i] <= defends[i]) result++;
    }
    return result;
  }

  /// Get the countries ids owned by [playerId].
  Set<String> playerCountries(int playerId) => countries.values.where((c) => c.playerId == playerId).map((c) => c.countryId).toSet();

  /**
   * Computes reinforcement for a [playerId] in this game.
   * Reinforcement = (Number of countries player owns) / 3 + (Continent bonus)
   * Continent bonus is added if player owns all the countries of a continent.
   * If reinforcement is less than three, round up to three.
   */
  int computeReinforcement(int playerId) {
    var playerCountries = this.playerCountries(playerId);
    var continents = CONTINENTS.where((c) => c.countries.every(playerCountries.contains));
    var bonus = continents.map((c) => c.bonus).fold(0, (a, b) => a + b);
    return max(3, playerCountries.length ~/ 3 + bonus);
  }

  /// Updates this Risk game state for the incoming [event].
  void update(EngineEvent event) {
    events.add(event);
    if (event is PlayerJoined) {
      players[event.playerId] = new PlayerStateImpl(event.playerId, event.name, event.avatar, event.color);
    } else if (event is GameStarted) {
      started = true;
      setupPhase = true;
      playersOrder = event.playersOrder;
      players.values.forEach((ps) => ps.reinforcement = event.armies);
    } else if (event is ArmyPlaced) {
      countries.putIfAbsent(event.country, () => new CountryStateImpl(event.country, playerId: event.playerId)).armies++;
      players[event.playerId].reinforcement--;
    } else if (event is NextPlayer) {
      activePlayerId = event.playerId;
      players[event.playerId].reinforcement = event.reinforcement;
      turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;
    } else if (event is SetupEnded) {
      setupPhase = false;
    } else if (event is NextStep) {
      turnStep = turnStep == RiskGameState.TURN_STEP_REINFORCEMENT ? RiskGameState.TURN_STEP_ATTACK : RiskGameState.TURN_STEP_FORTIFICATION;
    } else if (event is BattleEnded) {
      countries[event.attacker.country].armies = event.attacker.remainingArmies;
      countries[event.defender.country].armies = event.defender.remainingArmies;
      if (event.conquered) {
        countries[event.defender.country].playerId = event.attacker.playerId;
      }
    } else if (event is ArmyMoved) {
      countries[event.from].armies -= event.armies;
      countries[event.to].armies += event.armies;
    } else if (event is PlayerLost) {
      players[event.playerId].dead = true;
    }
  }
}
