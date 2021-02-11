import 'dart:typed_data';

import 'package:meta_audio/metadata.dart';

class NativeArtwork extends Artwork {
  NativeArtwork(this._exists, this._data);
  final Future<Uint8List> Function() _data;
  final bool _exists;

  @override
  Future<Uint8List> data() {
    return _data();
  }

  @override
  bool get exists => _exists;
}
