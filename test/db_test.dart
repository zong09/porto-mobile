import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/db/database.dart';

void main() {
  test('schema v1 opens in-memory and round-trips a portfolio', () async {
    final db = AppDatabase(NativeDatabase.memory());
    expect(db.schemaVersion, 1);

    await db.into(db.portfolios).insert(
          PortfoliosCompanion.insert(id: 'p1', name: 'Main', color: 0),
        );
    final rows = await db.select(db.portfolios).get();
    expect(rows.length, 1);
    expect(rows.single.name, 'Main');

    await db.close();
  });
}
