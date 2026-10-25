import 'package:flutter/material.dart';

/// Metadata tampilan untuk setiap kategori.
///
/// Dipisahkan dari JSON supaya data tetap murni (mudah diganti API),
/// sementara warna & ikon tetap konsisten di seluruh aplikasi.
class CategoryInfo {
  const CategoryInfo({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.ikon,
    required this.warna,
  });

  /// Slug yang sama dengan field `kategori` pada JSON.
  final String id;
  final String nama;
  final String deskripsi;
  final IconData ikon;
  final Color warna;
}

class AppCategories {
  const AppCategories._();

  static const List<CategoryInfo> all = <CategoryInfo>[
    CategoryInfo(
      id: 'leher-bahu',
      nama: 'Leher & Bahu',
      deskripsi: 'Redakan kaku setelah menunduk lama.',
      ikon: Icons.accessibility_new_rounded,
      warna: Color(0xFFD97757),
    ),
    CategoryInfo(
      id: 'punggung',
      nama: 'Punggung',
      deskripsi: 'Jaga postur dan kelenturan tulang belakang.',
      ikon: Icons.airline_seat_recline_normal_rounded,
      warna: Color(0xFF3E7C8C),
    ),
    CategoryInfo(
      id: 'pergelangan-tangan',
      nama: 'Pergelangan Tangan',
      deskripsi: 'Kurangi tegang akibat mengetik dan mouse.',
      ikon: Icons.back_hand_rounded,
      warna: Color(0xFFC89B3C),
    ),
    CategoryInfo(
      id: 'kaki',
      nama: 'Kaki',
      deskripsi: 'Aktifkan kaki yang jarang bergerak.',
      ikon: Icons.directions_walk_rounded,
      warna: Color(0xFF7A6A9B),
    ),
  ];

  /// Fallback ke kategori pertama bila slug tidak dikenal,
  /// sehingga UI tidak pernah crash karena data baru dari API.
  static CategoryInfo byId(String id) {
    return all.firstWhere(
      (category) => category.id == id,
      orElse: () => all.first,
    );
  }

  static String labelOf(String id) => byId(id).nama;
}
