import 'package:polymer/polymer.dart';

@CustomTag('risk-modal')
class RiskModal extends PolymerElement {
  @published
  String header;

  @published
  bool closable;

  RiskModal.created(): super.created();

  close() => fire('close');
}