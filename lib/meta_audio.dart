import 'dart:io';

import 'package:meta_audio/android/android_metadata_parser.dart';
import 'package:meta_audio/apple/apple_metadata_parser.dart';
import 'package:meta_audio/metadata.dart';
import 'package:meta_audio/metadata_parser.dart';

class MetaAudio extends MetadataParser {
  MetaAudio({this.parsers}) {
    if (parsers == null) {
      parsers = MetaAudio.defaultParsers;
    }
  }

  static List<MetadataParser> get defaultParsers {
    return [
      if (Platform.isIOS) AppleMetadataParser(),
      if (Platform.isAndroid) AndroidMetadataParser(),
    ];
  }

  List<MetadataParser> parsers;

  @override
  Future<Metadata> parse(String path, [Map<String, dynamic> options]) async {
    for (var parser in parsers) {
      final metadata = await parser.parse(path, options);
      if (metadata != null) {
        return metadata;
      }
    }

    return null;
  }
}
