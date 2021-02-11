import 'package:meta_audio/metadata.dart';
import 'package:meta_audio/native/native_metadata_parser.dart';

class AppleMetadataParser extends NativeMetadataParser {
  @override
  Future<Metadata> parse(String path, [Map<String, dynamic> options]) async {
    final Map<dynamic, dynamic> rawMetadata = await invokeGetMetadata(path);

    Duration duration;
    final durationInSecStr = rawMetadata['approximate duration in seconds'];
    if (durationInSecStr != null) {
      final durationSec = double.tryParse(durationInSecStr);
      if (durationSec != null) {
        final durationUs = durationSec * 1e6;
        duration = Duration(microseconds: durationUs.toInt());
      }
    }

    final trackValue = rawMetadata['track number'];
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

    final yearStr = rawMetadata['year'];
    int year;
    if (yearStr != null) {
      year = int.tryParse(yearStr);
    }

    return Metadata(
      path: path,
      duration: duration,
      title: rawMetadata['title'],
      album: rawMetadata['album'],
      artist: rawMetadata['artist'],
      genre: rawMetadata['genre'],
      composer: rawMetadata['composer'],
      trackNumber: trackNumber,
      trackCount: trackCount,
      year: year,
      artwork: invokeGetArtwork(path),
    );
  }
}
