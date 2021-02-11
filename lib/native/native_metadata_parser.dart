import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:meta_audio/metadata.dart';
import 'package:meta_audio/metadata_parser.dart';
import 'package:meta_audio/native/native_artwork.dart';

abstract class NativeMetadataParser extends MetadataParser {
  static const MethodChannel _channel = const MethodChannel('meta_audio');

  Future<T> invokeGetMetadata<T>(String path) {
    return _channel.invokeMethod<T>('metadata', path);
  }

  Future<Artwork> invokeGetArtwork(String path) async {
    final exists = await _channel.invokeMethod<bool>('artwork_exists', path);

    if (!exists) {
      return NativeArtwork(false, null);
    }

    final dataFunc = () => _channel.invokeMethod<Uint8List>('artwork', path);
    return NativeArtwork(true, dataFunc);
  }
}
