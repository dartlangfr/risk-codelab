import 'dart:convert';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:risk_engine/client.dart';
import 'package:risk_engine/snapshot.dart';
import 'package:risk/risk.dart';

@CustomTag('risk-game')
class RiskGame extends AbstractRiskGame {
  RiskGame.created(): super.created();

  // TODO: implement eventEngineCodec
  @override
  Codec<Object, Map> get eventEngineCodec => null; // EVENT

  @override
  final RiskGameState game = loadEventsAsync(new RiskGameStateImpl(), SNAPSHOT_GAME_ATTACK);

  /// Listen events on the given [webSocket].
  @override
  void listen(WebSocket ws) {
    ws.onMessage.map((e) => e.data).map(JSON.decode).map(logEvent("IN")).map(eventEngineCodec.decode).listen(handleEvents);
  }

  /// Send the given [event] through the WebSocket 
  @override
  void sendEvent(PlayerEvent event) {
    ws.send(logEvent('OUT')(JSON.encode(eventEngineCodec.encode(event))));
  }

  /// Send a JoinGame event though the WebSocket
  joinGame(CustomEvent e, var detail, Element target) => sendEvent(new JoinGame()
      ..playerId = playerId
      ..color = detail['color']
      ..avatar = detail['avatar']
      ..name = detail['name']);
}
