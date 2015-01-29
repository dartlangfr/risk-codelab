part of risk_engine.client;

/// Brings some logical facilitation for RiskBoard element
abstract class AbstractRiskBoardElement extends PolymerElement {
  /// The selected country
  String get selectedCountryId;
  set selectedCountryId(String value);
  /// The Risk game state
  RiskGameState get game;
  /// The connected playerId
  @published
  int playerId = 2;

  AbstractRiskBoardElement.created(): super.created();

  /**
   * Returns true if a country is selectable depending on the given arguments.
   */
  selectableCountry(String countryId, int activePlayerId, String turnStep, String selectedCountryId) {
    var handler = getClickHandler(countryId, activePlayerId, turnStep, selectedCountryId);
    return handler != countryUnselect && (selectedCountryId == null || handler != countrySelect);
  }

  countryClick(Event e, var detail, Element target) {
    var handler = getClickHandler(target.dataset['country'], game.activePlayerId, game.turnStep, selectedCountryId);
    handler(e, detail, target);
  }

  /**
   * Returns the correct click handler for a country depending on the given arguments.
   */
  getClickHandler(String countryId, int activePlayerId, String turnStep, String selectedCountryId) {
    if (activePlayerId != playerId) {
      return countryUnselect;
    } else if (turnStep == RiskGameState.TURN_STEP_REINFORCEMENT) {
      if (isMine(countryId)) return countryPlaceArmy;
    } else if (turnStep == RiskGameState.TURN_STEP_ATTACK) {
      if (countryId == selectedCountryId) return countryUnselect; else if (canAttackFrom(countryId)) return countrySelect; else if (selectedCountryId != null && canAttackTo(
          selectedCountryId, countryId)) return countryAttack;
    } else if (turnStep == RiskGameState.TURN_STEP_FORTIFICATION) {
      if (countryId == selectedCountryId) return countryUnselect; 
      else if (selectedCountryId != null && canFortifyTo(selectedCountryId, countryId)) return countryMove;
      else if (canFortifyFrom(countryId)) return countrySelect; 
    }
    return countryUnselect;
  }

  /// When a country is selected
  countrySelect(Event e, var detail, Element target) => selectedCountryId = target.dataset['country'];
  /// When a country is unselected
  countryUnselect(Event e, var detail, Element target) => selectedCountryId = null;
  /// When country is clicked to place an army
  countryPlaceArmy(Event e, var detail, Element target) => fire('selection', detail: target.dataset['country']);
  /// When country to attack is clicked with a previously selected country
  countryAttack(Event e, var detail, Element target) => fire('attack', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });
  /// When country where to move armies is clicked with a previously selected country
  countryMove(Event e, var detail, Element target) => fire('move', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });

  bool isMine(String country) => game.countries[country].playerId == playerId;
  bool isNotMine(String country) => !isMine(country);
  bool areNeighbours(String myCountry, String strangeCountry) => game.countryNeighbours(myCountry).contains(strangeCountry);
  bool canAttackFrom(String country) => isMine(country) && game.countries[country].armies > 1 && game.countryNeighbours(country).any((to) => isNotMine(to));
  bool canAttackTo(String from, String to) => isNotMine(to) && areNeighbours(from, to);
  bool canFortifyFrom(String country) => isMine(country) && game.countries[country].armies > 1 && game.countryNeighbours(country).any((to) => isMine(to));
  bool canFortifyTo(String from, String to) => isMine(to) && areNeighbours(from, to);
}


class Move extends Object with Observable {
  String from, to;
  int maxArmies;
  @observable int armiesToMove = 1;
}

const AUTO_SETUP = false;

/// Brings some logical facilitation for RiskGame element
abstract class AbstractRiskGame extends PolymerElement {
  Codec<Object, Map> get eventEngineCodec;
  
  @observable
  RiskGameState get game;

  final WebSocket ws;

  /// Current playerId
  @observable
  int playerId;

  /// Pending move after an attack or on fortification
  @observable
  Move pendingMove;

  AbstractRiskGame.created(): this.forUrl(_currentWebSocketUri());

  AbstractRiskGame.forUrl(String url): this.fromWebSocket(new WebSocket(url));
  
  AbstractRiskGame.fromWebSocket(this.ws): super.created() {
    listen(ws);
  }
  
  /// Listen events on the given [webSocket].
  void listen(WebSocket webSocket);

  /// Send the given [event] through the WebSocket 
  void sendEvent(PlayerEvent event);

  void handleEvents(EngineEvent event) {
    game.update(event);

    if (event is Welcome) {
      playerId = event.playerId;
    } else if (event is BattleEnded) {
      if (event.attacker.playerId == playerId) {
        if (event.defender.remainingArmies == 0) {
          if (event.attacker.remainingArmies == 2) {
            sendEvent(new MoveArmy()
                ..playerId = playerId
                ..from = event.attacker.country
                ..to = event.defender.country
                ..armies = 1);
          } else {
            var maxArmies = event.attacker.remainingArmies - 1;
            pendingMove = new Move()
                ..from = event.attacker.country
                ..to = event.defender.country
                ..maxArmies = maxArmies
                ..armiesToMove = maxArmies;
          }
        }
      }
    } else if (event is ArmyMoved) {
      pendingMove = null;
    } else if (event is NextPlayer) {
      if (AUTO_SETUP && game.setupPhase && event.playerId == playerId) {
        sendEvent(new PlaceArmy()
            ..playerId = playerId
            ..country = (game.countries.values.where((cs) => cs.playerId == playerId).map((cs) => cs.countryId).toList()..shuffle()).first);
      }
    }
  }

  /// Send a JoinGame event though the WebSocket
  joinGame(CustomEvent e, var detail, Element target);

  /// Send a Attack event though the WebSocket
  attack(CustomEvent e, var detail, Element target) => sendEvent(new Attack()
      ..playerId = playerId
      ..from = e.detail['from']
      ..to = e.detail['to']
      ..armies = min(3, game.countries[e.detail['from']].armies - 1));

  move(CustomEvent e, var detail, Element target) {
    var maxArmies = game.countries[e.detail['from']].armies - 1;
    pendingMove = new Move()
        ..from = e.detail['from']
        ..to = e.detail['to']
        ..maxArmies = maxArmies
        ..armiesToMove = maxArmies;
  }

  /// Send a StartGame event though the WebSocket
  startGame() => sendEvent(new StartGame()..playerId = playerId);

  /// Send a PlaceArmy event though the WebSocket
  selection(CustomEvent e, var detail, Element target) => sendEvent(new PlaceArmy()
      ..playerId = playerId
      ..country = e.detail);

  /// Send a MoveArmy event though the WebSocket
  moveArmies() => sendEvent(new MoveArmy()
      ..playerId = playerId
      ..from = pendingMove.from
      ..to = pendingMove.to
      ..armies = pendingMove.armiesToMove);

  /// Send a EndAttack event though the WebSocket
  endAttack() => sendEvent(new EndAttack()..playerId = playerId);

  /// Send a EndTurn event though the WebSocket
  endTurn() => sendEvent(new EndTurn()..playerId = playerId);

  logEvent(direction) => (event) {
    print("$direction - $event");
    return event;
  };
}

String _currentWebSocketUri() {
  var uri = Uri.parse(window.location.toString());
  return new Uri(scheme: "ws", host: uri.host, port: uri.port, path: "/ws").toString();
}
