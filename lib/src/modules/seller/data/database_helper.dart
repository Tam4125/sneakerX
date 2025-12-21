// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;
//
//   factory DatabaseHelper() => _instance;
//
//   DatabaseHelper._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'ecommerce.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     // Products table
//     await db.execute('''
//       CREATE TABLE products(
//         productId INTEGER PRIMARY KEY AUTOINCREMENT,
//         shopId INTEGER NOT NULL,
//         categoryId INTEGER NOT NULL,
//         name TEXT NOT NULL,
//         description TEXT,
//         price REAL NOT NULL,
//         stock INTEGER NOT NULL DEFAULT 0,
//         soldCount INTEGER NOT NULL DEFAULT 0,
//         rating REAL DEFAULT 0.0,
//         status TEXT NOT NULL DEFAULT 'active',
//         createdAt TEXT NOT NULL,
//         updatedAt TEXT NOT NULL,
//         FOREIGN KEY (shopId) REFERENCES sellers(shopId),
//         FOREIGN KEY (categoryId) REFERENCES categories(categoryId)
//       )
//     ''');
//
//     // Product Media table (supports both images and videos)
//     await db.execute('''
//       CREATE TABLE product_media(
//         mediaId INTEGER PRIMARY KEY AUTOINCREMENT,
//         productId INTEGER NOT NULL,
//         mediaUrl TEXT NOT NULL,
//         mediaType TEXT NOT NULL,
//         sortOrder INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY (productId) REFERENCES products(productId) ON DELETE CASCADE
//       )
//     ''');
//   }
//
//   // Insert product
//   Future<int> insertProduct(Product product) async {
//     final db = await database;
//     return await db.insert('products', product.toMap());
//   }
//
//   // Insert product media
//   Future<int> insertProductMedia(ProductMedia media) async {
//     final db = await database;
//     return await db.insert('product_media', media.toMap());
//   }
//
//   // Get product with media
//   Future<Map<String, dynamic>?> getProductWithMedia(int productId) async {
//     final db = await database;
//
//     final productList = await db.query(
//       'products',
//       where: 'productId = ?',
//       whereArgs: [productId],
//     );
//
//     if (productList.isEmpty) return null;
//
//     final mediaList = await db.query(
//       'product_media',
//       where: 'productId = ?',
//       whereArgs: [productId],
//       orderBy: 'sortOrder ASC',
//     );
//
//     return {
//       'product': Product.fromMap(productList.first),
//       'media': mediaList.map((m) => ProductMedia.fromMap(m)).toList(),
//     };
//   }
//
//   // Update product
//   Future<int> updateProduct(Product product) async {
//     final db = await database;
//     return await db.update(
//       'products',
//       product.toMap(),
//       where: 'productId = ?',
//       whereArgs: [product.productId],
//     );
//   }
//
//   // Delete product (cascade deletes media)
//   Future<int> deleteProduct(int productId) async {
//     final db = await database;
//     return await db.delete(
//       'products',
//       where: 'productId = ?',
//       whereArgs: [productId],
//     );
//   }
//
//   // Get all products
//   Future<List<Product>> getAllProducts() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('products');
//     return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
//   }
// }
