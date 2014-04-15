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

main(List<String> args) {
}
```

For the moment, it's just a simple empty main with few imports :
 * The `dart:async` import will be used for handle the asynchronious code.
 * `dart:io` library contains the HTTP server dart implementation.
 * `dart:convert` it's a kind of codec library used to decode/encode many formats.
 * `package:http_server/http_server.dart` it's a lib who come from the pub and it will be used to expose a virtual directory
 * `package:risk/risk` contains the core code of the rick game
 
### Expose the index.html file

Since the begining of this workshop when you ran your web app, Dartium started a web server on the fly who exposed the HTML files (and all others assets). So, your task will be to create a server who will expose your HTML files. In a first step, add the default port and directory, and the mechanism to override them :

```Dart
library risk.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk/risk.dart';

const DEFAULT_PORT = 8080;
const DEFAULT_PATH = '../web';

main(List<String> args) {
  int port = args.length > 0 ? int.parse(args[0], onError: (_) => DEFAULT_PORT) : DEFAULT_PORT;
  String path = Platform.script.resolve(args.length > 1 ? args[1] : DEFAULT_PATH).toFilePath();
}
```

Key information:
 * We define the two defaults values with `const DEFAULT_PORT = 8080;` and `const DEFAULT_PATH = '../web';`. Note that they are `const` and not `static` or `final` variables who exist too in dart, go [here](http://news.dartlang.org/2012/06/const-static-final-oh-my.html) to have more details about theirs differences
 * The top-level `main` function in Dart the entry point of the programme like Java, and like Java you can pass arguments by command line to the program when it be started. The two lines in the `main` function are just two ternary operator to override the default values if their are passed.
 
Continue to edit the `bin/main.dart` file to add the server listening :

```Dart
library risk.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk/risk.dart';

const DEFAULT_PORT = 8080;
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

Let's try your server :
 * With your terminal, go into the `ROOT_PROJECT/s9_server` directory.
 * run the `pub bin/main.dart` command.
 
You should see _"Risk is running on http://localhost:8080
Base path: /home/you/risk-codelab-master/samples/s9_server/web"_

Check if the web interface is available, open Chromium and go to `http://localhost:8080`. You should the famous index page.

Ok, what have we just done ?
 * We have declared a variable named `vDir` of type `VirtualDirectory`. A virtual directory in a dart web server it's a directory who will be exposed on the web, but who doesn't necessary exist on the hard drive. It's usefull when you need to simulate a tree.
 * After, with `HttpServer.bind(InternetAddress.ANY_IP_V4, port)` we create an HTTP server who listen on the given port.
 * In its `then` callback (indeed the `bind` method return a future resolved when the server is ready to listen) we initialize the `vDir` var with a instance of `VirtualDirectory` with its root dir not jailed, with directory listing authorized, and a `directoryHandler`
 * Here the `directoryHandler` is a top-level function who will expose only the `index.html`. It's a very limiter directory handler but we don't need more for the purpose of the workshop.
 * Finally, we add a listener handler of the client request and we forward this request directly to the virtual directory.
 
 
To finish this first part, we will add a a security for our server be more reliable. In Dart like in the Angular project ([learn more](https://github.com/btford/zone.js/)) , the Google Teams have introduce a concept of "Zone".
A Zone in Dart it's a container for asynchronious code ensuring that any error of exceptional behavior don't impect the rest of the program and keep it safe. Modify the 'bin/main.dart' file to wrap our server initialising and listening with this container, like this :

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
 * `runZoned` it's a simple top-level function who execute its callback passed in parameter in a new seperate zone. The second argumennt of this function is the error handler.
 
To check if all continue to work correctly, just stop restart your running server and check your browser.

### Problems?
Check your code against the files in [s9_server](../samples/s9_server).

## [Home](../README.md#code-lab-polymerdart) | [< Previous](step-8.md#step-8-event-serialization) | [Next >](step-10.md#step-10-put-it-all-together)
