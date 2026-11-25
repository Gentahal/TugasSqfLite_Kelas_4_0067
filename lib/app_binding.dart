import 'package:get/get.dart';
import 'package:learn_storage/controller/barang_controller.dart';
import 'package:learn_storage/data/dao/barang_dao.dart';
import 'package:learn_storage/data/database/db_helper.dart';
import 'package:learn_storage/data/repo/barang_repo.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DbHelper>(() => DbHelper(), fenix: true);
    Get.lazyPut<BarangDao>(() => BarangDao(Get.find<DbHelper>()));
    Get.lazyPut<BarangRepo>(() => BarangRepoImpl(Get.find<BarangDao>()));
    Get.lazyPut<BarangController>(
      () => BarangController(Get.find<BarangRepo>()),
    );
  }
}
