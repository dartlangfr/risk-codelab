library risk_engine.components.panel;

@MirrorsUsed(targets: const ['risk_engine.components.panel'])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:polymer_expressions/filter.dart' show Transformer;

import 'package:risk_engine/client.dart';

@CustomTag('risk-panel')
class RiskPanel extends PolymerElement {
  @published
  RiskGameState game;

  @published
  int playerId;

  @published
  Move pendingMove;

  final asInteger = new StringToInt();

  RiskPanel.created(): super.created();

  startGame() =>  fire('startgame');
  moveArmies() => fire('movearmies');
  endAttack() => fire('endattack');
  endTurn() => fire('endturn');
}

class StringToInt extends Transformer<String, int> {
  String forward(int i) => '$i';
  int reverse(String s) => int.parse(s);
}