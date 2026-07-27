import 'dart:io';

void main() {
  final f1 = File('assets/mock/menu.json');
  final c1 = f1.readAsStringSync();
  f1.writeAsStringSync(c1.replaceAllMapped(RegExp(r'placehold\.co/([^?]+)\?'), (m) => 'placehold.co/${m[1]}.png?'));

  final f2 = File('assets/mock/categories.json');
  final c2 = f2.readAsStringSync();
  f2.writeAsStringSync(c2.replaceAllMapped(RegExp(r'placehold\.co/([^?]+)\?'), (m) => 'placehold.co/${m[1]}.png?'));
}
