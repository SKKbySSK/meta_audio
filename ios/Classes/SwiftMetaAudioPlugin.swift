import Flutter
import AVFoundation

public class SwiftMetaAudioPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "meta_audio", binaryMessenger: registrar.messenger())
    let instance = SwiftMetaAudioPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arg = call.arguments as? String
    switch call.method {
    case "metadata":
      guard let path = arg else {
        result(nil)
        return
      }
      getMetadata(path: path, result: result)
    case "artwork":
      guard let path = arg else {
        result(nil)
        return
      }
      let artwork = getArtwork(path: path, result: result)
      result(artwork)
    case "artwork_exists":
      guard let path = arg else {
        result(nil)
        return
      }
      let artwork = getArtwork(path: path, result: result)
      result(artwork != nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func getAudioProperty<Result>(path: String, result: @escaping FlutterResult, propertyId: AudioFilePropertyID, out: inout Result?) -> Bool {
    let url = URL(fileURLWithPath: path)
    
    var fileID: AudioFileID? = nil
    var status: OSStatus = AudioFileOpenURL(url as CFURL, .readPermission, 0, &fileID)

    guard status == noErr, let audioFile = fileID else {
      result(FlutterError(code: "ERR_OPEN", message: nil, details: status))
      return false
    }
    
    var dataSize = UInt32(MemoryLayout<Result?>.size(ofValue: out))
    status = AudioFileGetProperty(audioFile, propertyId, &dataSize, &out)

    guard status == noErr else {
      result(FlutterError(code: "ERR_READ", message: nil, details: status))
      return false
    }
    
    AudioFileClose(audioFile)
    return true
  }
  
  private func getMetadata(path: String, result: @escaping FlutterResult) {
    var dict: CFDictionary? = nil
    guard getAudioProperty(path: path, result: result, propertyId: kAudioFilePropertyInfoDictionary, out: &dict) else { return }

    guard let cfDict = dict else {
      result(Dictionary<String, Any>())
      return
    }

    let metaDict = NSDictionary(dictionary: cfDict)
    result(metaDict)
  }
  
  private func getArtwork(path: String, result: @escaping FlutterResult) -> NSData? {
    var data: CFData? = nil
    guard getAudioProperty(path: path, result: result, propertyId: kAudioFilePropertyAlbumArtwork, out: &data) else { return nil }
    
    guard let cfData = data else {
      result(nil)
      return nil
    }
    
    let artworkData = cfData as NSData
    return artworkData
  }
}
