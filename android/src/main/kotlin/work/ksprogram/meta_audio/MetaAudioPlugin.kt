package work.ksprogram.meta_audio

import android.media.MediaMetadataRetriever
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** MetaAudioPlugin */
class MetaAudioPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "meta_audio")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val path = call.arguments as? String
    if (path == null) {
      result.error("ERR_PATH", null, null)
      return
    }

    when (call.method) {
      "metadata" -> {
        getMetadata(path, result)
      }
      "artwork" -> {
        getArtwork(path, result)
      }
      "artwork_exists" -> {
        checkArtworkExists(path, result)
      }
      else -> result.notImplemented()
    }
  }

  private fun getMetadata(path: String, result: Result) {
    val retriever = MediaMetadataRetriever()
    retriever.setDataSource(path)

    val durationMsStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
    val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
    val album = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)
    val artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
    val genre = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_GENRE)
    val composer = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_COMPOSER)
    val trackNumberStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)
    val trackCountStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_NUM_TRACKS)
    val yearStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR)

    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
      retriever.close()
    }
    retriever.release()

    var duration = durationMsStr?.toDoubleOrNull()
    if (duration != null) {
      duration *= 1e3
    }

    val trackNumber = trackNumberStr?.toIntOrNull()
    val trackCount = trackCountStr?.toIntOrNull()
    val year = yearStr?.toIntOrNull()

    result.success(hashMapOf(
            "duration" to duration?.toInt(),
            "title" to title,
            "album" to album,
            "artist" to artist,
            "genre" to genre,
            "composer" to composer,
            "trackNumber" to trackNumber,
            "trackCount" to trackCount,
            "year" to year
    ))
  }

  private fun checkArtworkExists(path: String, result: Result) {
    val retriever = MediaMetadataRetriever()
    retriever.setDataSource(path)

    val picture = retriever.embeddedPicture

    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
      retriever.close()
    }
    retriever.release()

    result.success(picture != null)
  }

  private fun getArtwork(path: String, result: Result) {
    val retriever = MediaMetadataRetriever()
    retriever.setDataSource(path)

    val picture = retriever.embeddedPicture

    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
      retriever.close()
    }
    retriever.release()

    result.success(picture)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
