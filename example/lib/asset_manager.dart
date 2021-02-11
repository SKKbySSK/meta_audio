import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AssetManager {
  AssetManager._();

  // You should add test.mp3 to example/assets/ folder to test in your local workspace
  static const sampleAssetItem = 'test.m4a';
  static String _cachedSampleAssetItem;

  // Extract the asset data and export to the app's document directory
  static Future<String> exportMusicFile() async {
    if (_cachedSampleAssetItem != null) {
      return _cachedSampleAssetItem;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$sampleAssetItem');

    try {
      var data = await rootBundle.load('assets/$sampleAssetItem');
      await file.writeAsBytes(data.buffer.asInt8List());
      _cachedSampleAssetItem = file.path;

      return file.path;
    } catch (_) {
      return null;
    }
  }
}
