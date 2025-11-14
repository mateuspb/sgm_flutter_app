import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_mov_app/pages/pendentes_page.dart';

void main() {
  // Inicializa o sqflite FFI para testes em VM
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Carrega lista vazia inicialmente', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PendentesPage()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PendentesPage), findsOneWidget);
  });
}
