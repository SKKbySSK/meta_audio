import Flutter
import AVFoundation

public class SwiftMetaAudioPlugin: NSObject, FlutterPlugin {
  private let parsers: [AudioParser] = [AVAssetParser(), AudioFileParser()]
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "meta_audio", binaryMessenger: registrar.messenger())
    let instance = SwiftMetaAudioPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let path = call.arguments as! String
    let holder = ResultHolder(result: result)
    
    switch call.method {
    case "metadata":
      var data: [String: Any?] = [:]
      for parser in parsers {
        data = mergeData(data, parser.getMetadata(path: path))
      }
      
      holder.success(data: data)
    case "artwork":
      for parser in parsers {
        guard let data = parser.getArtwork(path: path) else { continue }
        holder.success(data: data)
      }
      
      holder.success(data: nil)
    case "artwork_exists":
      var data: [String: Any?] = [:]
      for parser in parsers {
        data = mergeData(data, parser.getMetadata(path: path))
      }
      
      holder.success(data: data["artwork"] ?? false)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func mergeData(_ first: [String: Any?], _ second: [String: Any?]) -> [String: Any?] {
    var data: [String: Any?] = first
    
    for (key, value) in second {
      if key == "artwork" {
        if let available = value as? Bool, available {
          data[key] = available
        }
      } else {
        guard data[key] == nil else {
          continue
        }
        
        data[key] = value
      }
    }
    
    return data
  }
}
