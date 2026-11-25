import 'package:get/get.dart';
import 'package:learn_storage/data/repo/barang_repo.dart';
import 'package:learn_storage/model/barang.dart';

class BarangController extends GetxController {
  final BarangRepo _repo;

  BarangController(this._repo);

  final barangList = <Barang>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadBarang();
  }

  Future<void> loadBarang() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repo.getAllBarang();
      barangList.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBarang(String nama, int stok) async {
    errorMessage.value = null;
    try {
      await _repo.insert(Barang(nama: nama, stok: stok));
      await loadBarang();
    } catch (e) {
      errorMessage.value = 'Gagal menambah barang: $e';
    }
  }

  Future<void> updateBarang(Barang barang) async {
    errorMessage.value = null;
    try {
      await _repo.update(barang);
      await loadBarang();
    } catch (e) {
      errorMessage.value = 'Gagal mengubah barang: $e';
    }
  }

  Future<void> deleteBarang(int id) async {
    errorMessage.value = null;
    try {
      await _repo.delete(id);
      await loadBarang();
    } catch (e) {
      errorMessage.value = 'Gagal menghapus barang: $e';
    }
  }
}

