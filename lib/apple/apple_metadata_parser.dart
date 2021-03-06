import 'package:meta_audio/metadata.dart';
import 'package:meta_audio/native/native_metadata_parser.dart';

class AppleMetadataParser extends NativeMetadataParser {
  @override
  Future<Metadata> parse(String path, [Map<String, dynamic> options]) async {
    final rawMetadata = await invokeGetMetadata(path);

    final title = rawMetadata['title'] as String;
    final album = rawMetadata['album'] as String;
    final artist = rawMetadata['artist'] as String;
    final genre = rawMetadata['genre'] as String;
    final composer = rawMetadata['composer'] as String;
    final year = rawMetadata['year'] as int;

    Duration duration;
    final durationSec = rawMetadata['duration'] as double;
    if (durationSec != null) {
      final durationUs = durationSec * 1e6;
      duration = Duration(microseconds: durationUs.toInt());
    }

    final trackValue = rawMetadata['track'];
    int trackNumber;
    int trackCount;

    if (trackValue != null) {
      // track number will be a number or '/' separated number which is like '1/5'
      final trackParsed = trackValue.split('/');
      switch (trackParsed.length) {
        case 0:
          break;
        case 1:
          trackNumber = int.tryParse(trackParsed[0]);
          break;
        default:
          trackNumber = int.tryParse(trackParsed[0]);
          trackCount = int.tryParse(trackParsed[1]);
          break;
      }
    }

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
