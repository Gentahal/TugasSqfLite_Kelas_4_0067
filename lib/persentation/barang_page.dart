import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learn_storage/controller/barang_controller.dart';
import 'package:learn_storage/model/barang.dart';

class BarangPage extends GetView<BarangController> {
  const BarangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        actions: [
          IconButton(
            onPressed: controller.loadBarang,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.barangList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.barangList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.loadBarang,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.barangList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada data barang.\nTekan tombol + untuk menambah.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.barangList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final barang = controller.barangList[index];
            return Card(
              child: ListTile(
                title: Text(barang.nama),
                subtitle: Text('Stok: ${barang.stok}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => _showFormDialog(context, barang: barang),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Hapus',
                      onPressed: () {
                        if (barang.id != null) {
                          _showDeleteDialog(context, barang);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        tooltip: 'Tambah Barang',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showFormDialog(BuildContext context, {Barang? barang}) async {
    final result = await showDialog<({String nama, int stok})>(
      context: context,
      builder: (_) => _BarangFormDialog(barang: barang),
    );

    if (result == null) return;

    if (barang != null) {
      await controller.updateBarang(
        barang.copyWith(nama: result.nama, stok: result.stok),
      );
    } else {
      await controller.addBarang(result.nama, result.stok);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, Barang barang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Barang'),
          content: Text('Yakin ingin menghapus "${barang.nama}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && barang.id != null) {
      await controller.deleteBarang(barang.id!);
    }
  }
}

class _BarangFormDialog extends StatefulWidget {
  final Barang? barang;

  const _BarangFormDialog({this.barang});

  @override
  State<_BarangFormDialog> createState() => _BarangFormDialogState();
}

class _BarangFormDialogState extends State<_BarangFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _stokController;

  bool get _isEdit => widget.barang != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.barang?.nama ?? '');
    _stokController = TextEditingController(
      text: widget.barang != null ? widget.barang!.stok.toString() : '',
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final nama = _namaController.text.trim();
    final stok = int.parse(_stokController.text.trim());
    Navigator.of(context).pop((nama: nama, stok: stok));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Barang' : 'Tambah Barang'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama barang wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stokController,
              decoration: const InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Stok wajib diisi';
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return 'Stok harus berupa angka >= 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}
