import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

late String _dbPath;

/// Links a Drift database to explorer
class DriftBridge {
  final GeneratedDatabase generatedDatabase;
  bool _isOpen = true;

  DriftBridge({required final String dbName, required this.generatedDatabase}) {
    _setup(dbName);
    _isOpen = true;
  }

  bool get isOpen => _isOpen;

  String get path => _dbPath;

  Future<void> clear({required String table}) async {
    if (!isOpen) return;
    final sql = 'DELETE FROM $table';
    await generatedDatabase.customWriteReturning(sql);
  }

  void close() {
    if (isOpen) generatedDatabase.close();
    _isOpen = false;
  }

  Future<List<Map<String, Object?>>> getTables() async {
    if (!isOpen) return [];
    final sql = "SELECT * FROM sqlite_master WHERE type = 'table'";
    return await rawSql(sql);
  }

  Future<List<Map<String, Object?>>> rawSql(String sql) async {
    List<Map<String, dynamic>> product = [];
    if (!isOpen) return product;
    Selectable<QueryRow> result = generatedDatabase.customSelect(sql);
    List<QueryRow> list = await result.get();
    list.forEach((QueryRow element) {
      product.add(element.data);
    });
    return product;
  }

  Future<int?> recordCount({required String tableName}) async {
    if (!isOpen) return null;
    final sql = "SELECT COUNT(*) FROM $tableName";
    final List<Map<String, Object?>> result = await rawSql(sql);
    return result[0].values.first as int;
  }

  _setup(String name) {
    return () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      _dbPath = p.join(dbFolder.path, name);
    };
  }
}
