// ignore_for_file: avoid_print

import 'dart:io';

import 'package:app/model/collision_grid.dart';

void main() {
  final bytes = File('assets/collision.bin').readAsBytesSync();
  final grid = CollisionGrid.fromBytes(bytes);

  // Registered spot coordinates (world space, +Z north).
  print('East gate front (578.5, 163.2): ${grid.isBlocked(578.5, 163.2)}');
  print('West gate front (-572.3, 342.9): ${grid.isBlocked(-572.3, 342.9)}');
  print('Connecting zone front (-82.4, 300.0): ${grid.isBlocked(-82.4, 300.0)}');
  print('Empowering zone front (253.9, 22.4): ${grid.isBlocked(253.9, 22.4)}');
  print('Saving zone front (-296.3, 73.8): ${grid.isBlocked(-296.3, 73.8)}');
  print('Signature zone center (-0.2, -97.9): ${grid.isBlocked(-0.2, -97.9)}');
  print('Quiet forest zone front (6.6, 105.2): ${grid.isBlocked(6.6, 105.2)}');
  print('East gate zone front (326.2, -71.8): ${grid.isBlocked(326.2, -71.8)}');
  print('West gate zone front (-312.8, 224.8): ${grid.isBlocked(-312.8, 224.8)}');
  print('Future life zone front (-690.8, 544.5): ${grid.isBlocked(-690.8, 544.5)}');

  // Buildings should be blocked.
  print('Japan pavilion center (391.2, -83.3): ${grid.isBlocked(391.2, -83.3)}');

  // Water plaza is open ground (no building collision there).
  print('Water plaza center (-68, -178): ${grid.isBlocked(-68, -178)}');
}
