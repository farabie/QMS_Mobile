part of '../models.dart';

class AssetTagging {
  final String assetName;
  final int urutan;

  AssetTagging({required this.assetName, required this.urutan});

  factory AssetTagging.fromJson(Map<String, dynamic> json) {
    return AssetTagging(
      assetName: json['asset_name'] ?? '',
      urutan: json['urutan'] ?? 0,
    );
  }
}
