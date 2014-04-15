library risk_engine;

// Declare libraries needed for Polymer in dart2js version
// risk should be declared in risk library but it's here just for exercise simplification
@MirrorsUsed(targets: const ['risk_engine', 'risk'])
import 'dart:mirrors';

import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'package:polymer/polymer.dart';

// Import common sources to be visible in this library scope
import 'risk_engine.dart';
// Export common sources to be visible to this library's users
export 'risk_engine.dart';

// Include specific client sources
part 'src/components.dart';
