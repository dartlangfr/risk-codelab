library risk_engine.components.history;

@MirrorsUsed(targets: const ['risk_engine.components.history'])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk_engine/risk_engine.dart';

@CustomTag('risk-history')
class RiskHistory extends PolymerElement {
  @published
  RiskGameState game;

  RiskHistory.created(): super.created() {
    var content = shadowRoot.querySelector("#content");
    
    scrollBottom(_) => content.scrollByPages(10);
    
    onPropertyChange(this, #game, () {
      (game.events as Observable).changes.listen(scrollBottom);
    });
  }

  bool isArmyMoved(EngineEvent e) => e is ArmyMoved;
  bool isArmyPlaced(EngineEvent e) => e is ArmyPlaced;
  bool isBattleEnded(EngineEvent e) => e is BattleEnded;
  bool isGameStarted(EngineEvent e) => e is GameStarted;
  bool isNextPlayer(EngineEvent e) => e is NextPlayer;
  bool isNextStep(EngineEvent e) => e is NextStep;
  bool isPlayerJoined(EngineEvent e) => e is PlayerJoined;
  bool isSetupEnded(EngineEvent e) => e is SetupEnded;
  bool isWelcome(EngineEvent e) => e is Welcome;
}