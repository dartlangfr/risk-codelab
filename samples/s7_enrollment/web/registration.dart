import 'dart:math';
import 'package:polymer/polymer.dart';

final _random = new Random();

@CustomTag('risk-registration')
class RiskRegistration extends PolymerElement {
  final List<String> avatars = ['ahmadi-nejad.png', 'bachar-el-assad.png',
      'caesar.png', 'castro.png', 'hitler.png', 'kadhafi.png', 'kim-jong-il.png',
      'mao-zedong.png', 'mussolini.png', 'napoleon.png', 'pinochet.png',
      'saddam-hussein.png', 'staline.png'];

  @observable
  String name;

  @observable
  String avatar;

  @observable
  String color;

  RiskRegistration.created(): super.created() {
    avatar = (avatars.toList()..shuffle(_random)).first;
    color = '#' + new List.generate(6, (_) => (6 + _random.nextInt(10)).toInt(
        ).toRadixString(16)).join();

    // notif isValid change
    notifyIsValid() => notifyPropertyChange(#isValid, null, isValid);
    onPropertyChange(this, #name, notifyIsValid);
    onPropertyChange(this, #avatar, notifyIsValid);
    onPropertyChange(this, #color, notifyIsValid);
  }

  int get avatarSelectedIndex => avatars.indexOf(avatar);
  set avatarSelectedIndex(int index) {
    avatar = avatars[index];
  }

  bool get isValid => [name, avatar, color].every((v) => v != null && v.trim(
      ).isNotEmpty);

  join() => fire('done', detail: {
    'name': name,
    'avatar': avatar,
    'color': color,
  });
}
