//
//  AudioFileParser.swift
//  meta_audio
//
//  Created by Kaisei Sunaga on 2021/02/12.
//

import Foundation
import AVFoundation
import Flutter

class AudioFileParser: AudioParser {
  func getMetadata(path: String) -> [String : Any?] {
    var dict: CFDictionary? = nil
    let status = getAudioProperty(path: path, propertyId: kAudioFilePropertyInfoDictionary, out: &dict)
    guard status == noErr else { return [:] }

    guard let cfDict = dict else {
      return [:]
    }

    let metaDict = NSDictionary(dictionary: cfDict)
    
    var data: [String: Any?] = [:]
    for (key, value) in metaDict {
      let keyStr = key as! String
      let valueStr = value as! String
      
      switch keyStr {
      case "track number":
        data["track"] = valueStr
      case "approximate duration in seconds":
        data["duration"] = Double(valueStr)
      case "year":
        data["year"] = Int(valueStr)
      default:
        data[keyStr] = valueStr
      }
    }
    
    data["artwork"] = getArtwork(path: path) != nil
    
    return data
  }
  
  func getArtwork(path: String) -> Data? {
    var data: CFData? = nil
    let status = getAudioProperty(path: path, propertyId: kAudioFilePropertyAlbumArtwork, out: &data)
    guard status == noErr else { return nil }

    guard let cfData = data else {
      return nil
    }

    return cfData as Data
  }
  
  private func getAudioProperty<Result>(path: String, propertyId: AudioFilePropertyID, out: inout Result?) -> OSStatus {
    let url = URL(fileURLWithPath: path)
    
    var fileID: AudioFileID? = nil
    var status: OSStatus = AudioFileOpenURL(url as CFURL, .readPermission, 0, &fileID)

    guard status == noErr, let audioFile = fileID else {
      return status
    }
    
    var dataSize = UInt32(MemoryLayout<Result?>.size(ofValue: out))
    status = AudioFileGetProperty(audioFile, propertyId, &dataSize, &out)
    AudioFileClose(audioFile)
    
    switch status {
    case kAudioFileStreamError_UnsupportedProperty:
      fallthrough
    case noErr:
      break
    default:
      return status
    }
    
    return status
  }
}
