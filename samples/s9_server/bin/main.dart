library risk.main;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk/risk.dart';
import 'package:risk_engine/server.dart';

const DEFAULT_PORT = 3000;
const DEFAULT_PATH = '../web';

VirtualDirectory vDir;

main(List<String> args) {
  int port = args.length > 0 ? int.parse(args[0], onError: (_) => DEFAULT_PORT) : DEFAULT_PORT;
  String path = Platform.script.resolve(args.length > 1 ? args[1] : DEFAULT_PATH).toFilePath();
  runZoned(() {
    HttpServer.bind(InternetAddress.ANY_IP_V4, port).then((server) {
      print("Risk is running on http://localhost:$port\nBase path: $path");
      vDir = new VirtualDirectory(path)
          ..jailRoot = false
          ..allowDirectoryListing = true
          ..directoryHandler = directoryHandler;
      var riskServer = new RiskWsServer();
      server.listen((HttpRequest req) {
        if (req.uri.path == '/ws') {
          WebSocketTransformer.upgrade(req).then(riskServer.handleWebSocket);
        } else if (req.uri.path == '/new') {
          riskServer = new RiskWsServer();
          req.response.redirect(req.uri.resolve('/'));
        } else {
          vDir.serveRequest(req);
        }
      });
    });
  }, onError: (e) => print("An error occurred $e"));
}

void directoryHandler(dir, request) {
  final indexUri = new Uri.file(dir.path).resolve('index.html');
  vDir.serveFile(new File(indexUri.toFilePath()), request);
}

class RiskWsServer extends AbstractRiskWsServer {
  final RiskGameEngine engine;

  Codec<Object, Map> get engineEventCodec => EVENT;

  RiskWsServer() : this.fromEngine(new RiskGameEngine(new StreamController.broadcast(), new RiskGameStateImpl()));
  RiskWsServer.fromEngine(this.engine);

  void listen(Stream ws, int playerId) {
    // Decode JSON
    ws.map(JSON.decode)
    // Log incoming events
    .map(logEvent("IN", playerId))
    // Decode events
    .map(EVENT.decode)
    // Avoid unknown events and cheaters
    .where((event) => event is PlayerEvent && event.playerId == playerId)
    // Handle events in game engine
    .listen(engine.handle)
    // Connection closed
    .onDone(() => print("Player $playerId left"));
  }
}