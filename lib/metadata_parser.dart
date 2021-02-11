import 'package:meta_audio/metadata.dart';

abstract class MetadataParser {
  Future<Metadata> parse(String path, [Map<String, dynamic> options]);
}
