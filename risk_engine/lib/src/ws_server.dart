part of risk_engine;

abstract class AbstractRiskWsServer {
  final Map<int, WebSocket> _clients = {};

  RiskGameEngine get engine;

  Codec<Object, Map> get engineEventCodec;

  int currentPlayerId = 1;

  void handleWebSocket(WebSocket ws) {
    final playerId = connectPlayer(ws);
    listen(ws, playerId);
  }

  void listen(Stream ws, int playerId);

  int connectPlayer(WebSocket ws) {
    int playerId = currentPlayerId++;

    _clients[playerId] = ws;

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()
      ..playerId = playerId);
    engine.history.forEach(stream.add);
    stream.addStream(engine.outputStream.stream);

    ws.addStream(stream.stream.map(engineEventCodec.encode).map(logEvent("OUT", playerId)).map(JSON.encode));

    print("Player $playerId connected");
    return playerId;
  }

  logEvent(String direction, int playerId) => (event) {
    print("$direction[$playerId] - $event");
    return event;
  };
}