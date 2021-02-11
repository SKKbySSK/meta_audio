import 'package:meta_audio/metadata.dart';
import 'package:meta_audio/native/native_metadata_parser.dart';

class AndroidMetadataParser extends NativeMetadataParser {
  @override
  Future<Metadata> parse(String path, [Map<String, dynamic> options]) async {
    final Map<dynamic, dynamic> rawMetadata = await invokeGetMetadata(path);

    final durationUs = rawMetadata['duration'] as int;
    Duration duration;
    if (durationUs != null) {
      duration = Duration(microseconds: durationUs);
    }

    final title = rawMetadata['title'] as String;
    final album = rawMetadata['album'] as String;
    final artist = rawMetadata['artist'] as String;
    final genre = rawMetadata['genre'] as String;
    final composer = rawMetadata['composer'] as String;
    final trackNumber = rawMetadata['trackNumber'] as int;
    final trackCount = rawMetadata['trackCount'] as int;
    final year = rawMetadata['year'] as int;

    return Metadata(
      path: path,
      duration: duration,
      title: title,
      album: album,
      artist: artist,
      genre: genre,
      composer: composer,
      trackNumber: trackNumber,
      trackCount: trackCount,
      year: year,
      artwork: invokeGetArtwork(path),
    );
  }
}
