import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
	static DbHelper? _dbHelper;
	static Database? _database;

	final String languageTable = 'language_table';
	final String code = 'code';

	final String savedArticlesTable = 'saved_articles';
	final String articleId = 'id';
	final String title = 'title';
	final String source = 'source';
	final String publishedAt = 'publishedAt';
	final String description = 'description';
	final String url = 'url';
	final String urlToImage = 'urlToImage';

	DbHelper._createInstance();

	factory DbHelper() {
		return _dbHelper ??= DbHelper._createInstance();
	}

	Future<Database> get database async {
		return _database ??= await initializeDatabase();
	}

	Future<Database> initializeDatabase() async {
		Directory directory = await getApplicationDocumentsDirectory();
		String path = '${directory.path}/insight360.db';

		var database = await openDatabase(
			path,
			version: 1,
			onCreate: _createDb,
			onUpgrade: _upgradeDb,
		);
		return database;
	}

	Future<void> deleteExistingDatabase() async {
		Directory directory = await getApplicationDocumentsDirectory();
		String path = '${directory.path}/insight360.db';
		File databaseFile = File(path);
		if (await databaseFile.exists()) {
			await databaseFile.delete();
			print("Existing database deleted.");
		}
	}

	void _createDb(Database db, int newVersion) async {
		try {
			await db.execute('CREATE TABLE IF NOT EXISTS $languageTable('
					'$articleId INTEGER PRIMARY KEY AUTOINCREMENT,'
					'$code TEXT NOT NULL);');

			await db.execute('CREATE TABLE IF NOT EXISTS $savedArticlesTable('
					'$articleId INTEGER PRIMARY KEY AUTOINCREMENT,'
					'$title TEXT,'
					'$source TEXT,'
					'$publishedAt TEXT,'
					'$description TEXT,'
					'$url TEXT,'
					'$urlToImage TEXT);');
			print("Tables created successfully.");
		} catch (e) {
			print("Error creating tables: $e");
		}
	}

	void _upgradeDb(Database db, int oldVersion, int newVersion) async {
		if (oldVersion < 2) {
			try {
				await db.execute('CREATE TABLE IF NOT EXISTS $savedArticlesTable('
						'$articleId INTEGER PRIMARY KEY AUTOINCREMENT,'
						'$title TEXT,'
						'$source TEXT,'
						'$publishedAt TEXT,'
						'$description TEXT,'
						'$url TEXT,'
						'$urlToImage TEXT);');
				print("Database upgraded to include $savedArticlesTable.");
			} catch (e) {
				print("Error upgrading database: $e");
			}
		}
	}

	Future<List<Map<String, dynamic>>> getLanguageMapList() async {
		Database db = await database;
		return await db.query(languageTable);
	}

	Future<List<String>> getLanguageList() async {
		final Database db = await database;
		final List<Map<String, dynamic>> maps =
		await db.query(languageTable, columns: [code]);
		return List<String>.from(maps.map((map) => map[code].toString()));
	}

	Future<int> insertLanguage(Map<String, Object?> language) async {
		Database db = await database;
		return await db.insert(languageTable, language);
	}

	Future<int> deleteAllLanguages() async {
		Database db = await database;
		return await db.delete(languageTable);
	}

	Future<int> deleteLanguage(String code) async {
		Database db = await database;
		return await db.delete(languageTable, where: '$code = ?', whereArgs: [code]);
	}

	Future<String?> getSelectedLanguage() async {
		final Database db = await database;
		final List<Map<String, dynamic>> result = await db.query(
			languageTable,
			columns: [code],
			limit: 1,
		);
		return result.isNotEmpty ? result.first[code] as String : null;
	}

	Future<int> saveArticle(Map<String, Object?> article) async {
		Database db = await database;
		return await db.insert(
			savedArticlesTable,
			article,
			conflictAlgorithm: ConflictAlgorithm.replace,
		);
	}

	Future<List<Map<String, dynamic>>> getSavedArticles() async {
		Database db = await database;
		return await db.query(savedArticlesTable);
	}

	Future<int> deleteArticle(int id) async {
		Database db = await database;
		return await db.delete(
			savedArticlesTable,
			where: '$articleId = ?',
			whereArgs: [id],
		);
	}

	Future<int> deleteAllArticles() async {
		Database db = await database;
		return await db.delete(savedArticlesTable);
	}
}
