## Step 9: Server side

_**Keywords**: server, virtual directory, websocket_


It's time for you to begin the server side of the dart programming. To getting starting, take a look to `bin/main.dart` file, it's where you will code your server :

```Dart
library risk.main;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk/risk.dart';
import 'package:risk_engine/server.dart';

main(List<String> args) {
}
```

For the moment, it's just a simple empty main with few imports :
 * The `dart:async` import will be used for handle the asynchronious code.
 * `dart:io` library contains the HTTP server dart implementation.
 * `dart:convert` it's a kind of codec library used to decode/encode many formats.
 * `package:http_server/http_server.dart` it's a lib who come from the pub and it will be used to expose a virtual directory.
 * `package:risk/risk` contains the core code of the risck game.
 
### Expose the index.html file

Since the begining of this workshop, when you ran your web app, Dartium started a web server on the fly who exposed the HTML files (and all others assets). So, your task will be to create a server who will expose your HTML files. In a first step, add the default port and directory, and the mechanism to override them :

```Dart
library risk.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk_engine/server.dart';
import '../lib/risk.dart';

const DEFAULT_PORT = 3000;
const DEFAULT_PATH = '../web';

main(List<String> args) {
  int port = args.length > 0 ? int.parse(args[0], onError: (_) => DEFAULT_PORT) : DEFAULT_PORT;
  String path = Platform.script.resolve(args.length > 1 ? args[1] : DEFAULT_PATH).toFilePath();
}
```

Key information:
 * We define the two defaults values with `const DEFAULT_PORT = 3000;` and `const DEFAULT_PATH = '../web';`. Note that they are `const` and not `static` or `final` variables who exist too in dart, go [here](http://news.dartlang.org/2012/06/const-static-final-oh-my.html) to have more details about theirs differences
 * The top-level `main` function in Dart is the entry point of the software like Java, and like Java you can pass arguments by command line to the program when it's started. The two lines in the `main` function are just two ternary operators to override the default values.
 
Continue to edit the `bin/main.dart` file to add the server listening :

```Dart
library risk.server;

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

  HttpServer.bind(InternetAddress.ANY_IP_V4, port).then((server) {
    print("Risk is running on http://localhost:$port\nBase path: $path");
    vDir = new VirtualDirectory(path)
      ..jailRoot = false
      ..allowDirectoryListing = true
      ..directoryHandler = directoryHandler;
    server.listen((HttpRequest req) {
      vDir.serveRequest(req);
    });
  });
}

void directoryHandler(dir, request) {
  final indexUri = new Uri.file(dir.path).resolve('index.html');
  vDir.serveFile(new File(indexUri.toFilePath()), request);
}
```

Let's try your server:
 * Right click on the `bin/main.dart` file then **Run**.

You should see in the IDE console window:
```
Risk is running on http://localhost:3000
Base path: /home/you/risk-codelab-master/samples/s9_server/web"
```

Check if the web interface is available, open Dartium and go to `http://localhost:3000`. You should see the famous index page.


Ok, what have we just done ?
 * We have declared a variable named `vDir` of type `VirtualDirectory`. A virtual directory in a dart web server it's a directory who will be exposed on the web, but who doesn't necessary exist on the hard drive. It's usefull when you need to simulate a tree.
 * After, with `HttpServer.bind(InternetAddress.ANY_IP_V4, port)` we create an HTTP server who listen on the given port.
 * In its `then` callback (indeed, the `bind` method returns a future resolved when the server is ready to listen) we initialize the `vDir` var with a instance of `VirtualDirectory` with its root dir not jailed, with directory listing authorized, and a `directoryHandler`
 * Here, the `directoryHandler` is a top-level function who will expose only the `index.html`. It's a very limited directory handler but we don't need more for the purpose of the workshop.
 * Finally, we add a listener handler of the client request and we forward this request directly to the virtual directory.
 
 
To finish this first part, we will add a security in order to our server be more reliable. In Dart, like in the Anuglar project( (learn more)[https://github.com/btford/zone.js/] ) , the Google Teams have introduce a concept of "Zone".
A Zone in Dart, it's a container for asynchronous code ensuring that any error or exceptional behavior don't impact the rest of the application and keep it safe. Modify the `bin/main.dart` file to wrap our server initialization and listen safely with this container, like this :

```Dart
// imports & vars ....
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
      server.listen((HttpRequest req) {
        vDir.serveRequest(req);
      });
    });
  }, onError: (e) => print("An error occurred $e"));
}
// others functions ...
```

Key information:
 * `runZoned` it's a simple top-level function who execute its callback passed in parameter in a new separate zone. The second argument of this function is the error handler.
 
To check if all still working correctly, just restart your server and check your browser.

### Handle WebSocket communication

Now, we have the static html file exposed, we will need to handle websocket communications between the server and each client. Because deal with web socket it's a long task, we have reduce it in the implementation of just one method.
For clarification, read the file `risk_engine/lib/src/ws_server.dart` who contains good part of the job:
 
```Dart
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
```

Key information :
 * AbstractRiskWsServer is an abstract class, you will need to extend in a concrete class  to use its behavior.
 * It contains a `_clients` variable to keep the connexions status of the clients, a `RiskGameEngine` instance who own the game states, and a `engineEventCodec` who will be mapped to the `EVENT` codec in the concrete class.
 * The `connnectPlayer` method has the responsability to spawn a new `StreamController`, attached to the new websocket of the new connected player.
 * The `handleWebSocket` will be called each time that the server will receive a new websocket request. It will find the concerned player id and will call the `listen` method. This is the method on which we will focus.
 
Comeback to `bin/main.dart` and add this following : 
 
```Dart
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
```

Key information :
 * On the beginning of the `RiskWsServer` we find few variables and constructor overriding not really important for you.
 *  After we find the famous `listen` method, step by step it accomplishes :
 	* Decoding JSON coming from the web socket request
 	* Logging of the event
 	* Transforming the JSON object to the corresponding Event Object
 	* Preventing that the previous step well done and there has not cheat
 	* To finish we deleguate the rest of the game behavior to the game engine and we log if the player left.
 	You note the simplicity of the treatment thanks to chaining of the future object.
 	
It remains, to route the HTTP request to this class to terminate this step. Edit as follow the part of `bin/main.dart` where the server listening:

```Dart
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
```

Key information :
 * This chunk of code, routes the http requests to the `RiskServer` instance when the http request tries to access to a WS service. You note how it's easy to upgrade a classic http request to an WebSocket request by using the `WebSocketTransformer` class.
 * If the request targets the 'new' service we overwrite the `riskServer` instance with a new one in order to reset all the connections and game engine states.
 
You can restart your server in your terminal.


### Problems?
Check your code against the files in [s9_server](../samples/s9_server) ([diff](../../../compare/s8_serialization...s9_server)).

## [Home](../README.md#code-lab-polymerdart) | [< Previous](step-8.md#step-8-event-serialization) | [Next >](step-10.md#step-10-put-it-all-together)
