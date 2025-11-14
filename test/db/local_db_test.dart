import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_mov_app/db/local_db.dart';
import 'package:flutter_mov_app/models/movimentacao.dart';

Movimentacao makeMov({
  required int id,
  String? assinatura,
}) {
  return Movimentacao(
    id: id,
    veiculo: 1,
    cliente: 1,
    pesoCarregado: 0,
    motorista: 1,
    produto: 1,
    observacoes: '',
    tipoCarga: 1,
    situacao: 1,
    assinaturaBase64: assinatura,
    dataAssinatura: assinatura != null ? '2025-10-10' : null,
    dataCriacao: '2025-10-09',
    clienteNome: 'Cli',
    produtoNome: 'Prod',
    motoristaNome: 'Mot',
    veiculoPlaca: 'AAA-0000',
    tipoCargaNome: 'Tipo',
    situacaoNome: 'Sit',
  );
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('cria e limpa tabelas', () async {
    final db = LocalDB();
    await db.clear(); // não deve lançar
  });

  test('insere movimentacoes e consulta pendentes', () async {
    final db = LocalDB();
    final movs = <Movimentacao>[
      makeMov(id: 1),
      makeMov(id: 2, assinatura: 'xxx'),
    ];
    // LocalDB.upsertMovs espera List<Map<String,dynamic>>
    await db.upsertMovs(movs.map((m) => m.toMap()).toList());
    final pend = await db.listPendentes();
    final ids = pend.map((e) => e['id']).toList();
    expect(ids, contains(1));
    expect(ids, isNot(contains(2)));
  });

  test('fila offline: add e remove', () async {
    final db = LocalDB();
    await db.queueSignature(1, 'b64', '2025-10-10');
    final list = await db.listQueued();
    expect(list, isNotEmpty);
    await db.removeQueued(1);
    final list2 = await db.listQueued();
    expect(list2, isEmpty);
  });
}
