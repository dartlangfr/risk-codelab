import 'dart:html';
import 'package:polymer/polymer.dart';

@CustomTag('risk-game')
class RiskGame extends PolymerElement {
  RiskGame.created() : super.created();

  joinGame(CustomEvent e, var detail, Element target) => print(detail);
}