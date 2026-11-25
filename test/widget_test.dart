import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:learn_storage/controller/barang_controller.dart';
import 'package:learn_storage/data/repo/barang_repo.dart';
import 'package:learn_storage/model/barang.dart';
import 'package:learn_storage/persentation/barang_page.dart';

class FakeBarangRepo implements BarangRepo {
  final List<Barang> _items = [];
  int _nextId = 1;

  @override
  Future<int> insert(Barang barang) async {
    final id = _nextId++;
    _items.insert(0, barang.copyWith(id: id));
    return id;
  }

  @override
  Future<List<Barang>> getAllBarang() async {
    return List<Barang>.from(_items);
  }

  @override
  Future<int> update(Barang barang) async {
    final index = _items.indexWhere((e) => e.id == barang.id);
    if (index == -1) return 0;
    _items[index] = barang;
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    return before - _items.length;
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<BarangController>(BarangController(FakeBarangRepo()));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('BarangPage CRUD flow works', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: BarangPage()));
    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada data barang.\nTekan tombol + untuk menambah.'),
      findsOneWidget,
    );

    // Tambah barang
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Buku Tulis');
    await tester.enterText(find.byType(TextFormField).at(1), '10');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Buku Tulis'), findsOneWidget);
    expect(find.text('Stok: 10'), findsOneWidget);

    // Edit barang
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Buku Gambar');
    await tester.enterText(find.byType(TextFormField).at(1), '5');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Buku Gambar'), findsOneWidget);
    expect(find.text('Stok: 5'), findsOneWidget);

    // Hapus barang
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Buku Gambar'), findsNothing);
    expect(
      find.text('Belum ada data barang.\nTekan tombol + untuk menambah.'),
      findsOneWidget,
    );
  });
}
