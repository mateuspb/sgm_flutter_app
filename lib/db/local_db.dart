import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class LocalDB {
  static final LocalDB _instance = LocalDB._internal();
  factory LocalDB() => _instance;
  LocalDB._internal();

  static const _dbName = 'sgm.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movimentacoes (
            id INTEGER PRIMARY KEY,
            veiculo INTEGER,
            cliente INTEGER,
            peso_carregado REAL,
            motorista INTEGER,
            produto INTEGER,
            observacoes TEXT,
            tipo_carga INTEGER,
            situacao INTEGER,
            assinatura_base64 TEXT,
            data_assinatura TEXT,
            data_criacao TEXT,
            cliente_nome TEXT,
            produto_nome TEXT,
            motorista_nome TEXT,
            veiculo_placa TEXT,
            tipo_carga_nome TEXT,
            situacao_nome TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE assinaturas_offline (
            mov_id INTEGER PRIMARY KEY,
            assinatura_base64 TEXT NOT NULL,
            data_assinatura TEXT NOT NULL
          );
        ''');
      },
    );
    return _db!;
  }

  Future<void> upsertMovs(List<Map<String, dynamic>> items) async {
    final db = await database;
    final batch = db.batch();
    for (final m in items) {
      batch.insert(
        'movimentacoes',
        m,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> listMovs() async {
    final db = await database;
    return db.query('movimentacoes', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> listPendentes() async {
    final db = await database;
    return db.query(
      'movimentacoes',
      where: """(assinatura_base64 IS NULL OR assinatura_base64 = '')
        AND id NOT IN (SELECT mov_id FROM assinaturas_offline)""",
      orderBy: 'id DESC',
    );
  }

  Future<void> setLocalAssinatura(
      int id, String assinaturaB64, String dataAssinatura) async {
    final db = await database;
    await db.update(
      'movimentacoes',
      {'assinatura_base64': assinaturaB64, 'data_assinatura': dataAssinatura},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> queueSignature(
      int movId, String assinaturaB64, String dataAssinatura) async {
    final db = await database;
    await db.insert(
      'assinaturas_offline',
      {
        'mov_id': movId,
        'assinatura_base64': assinaturaB64,
        'data_assinatura': dataAssinatura
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> listQueued() async {
    final db = await database;
    return db.query('assinaturas_offline', orderBy: 'mov_id DESC');
  }

  Future<void> removeQueued(int movId) async {
    final db = await database;
    await db
        .delete('assinaturas_offline', where: 'mov_id = ?', whereArgs: [movId]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('movimentacoes');
    await db.delete('assinaturas_offline');
  }
}
