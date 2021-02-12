//
//  AVAssetParser.swift
//  meta_audio
//
//  Created by Kaisei Sunaga on 2021/02/13.
//

import Foundation
import AVFoundation

class AVAssetParser: AudioParser {
  func getMetadata(path: String) -> [String : Any?] {
    let url = URL(fileURLWithPath: path)
    let asset = AVAsset(url: url)
    
    var data: [String: Any?] = [:]
    self.handleCommonKeys(metadata: asset.commonMetadata, data: &data)
    
    for format in asset.availableMetadataFormats {
      switch format {
      case .iTunesMetadata:
        self.handleiTunes(metadata: asset.metadata(forFormat: format), data: &data)
      case .id3Metadata:
        self.handleID3(metadata: asset.metadata(forFormat: format), data: &data)
      default:
        print(format)
        break
      }
    }
    
    return data
  }
  
  func getArtwork(path: String) -> Data? {
    let url = URL(fileURLWithPath: path)
    let asset = AVAsset(url: url)
    guard let artwork = asset.commonMetadata.first(where: { $0.commonKey == AVMetadataKey.commonKeyArtwork }) else {
      return nil
    }
    
    return artwork.dataValue
  }
  
  private func handleCommonKeys(metadata: [AVMetadataItem], data: inout [String: Any?]) {
    for item in metadata {
      switch item.commonKey {
      case AVMetadataKey.commonKeyTitle:
        data["title"] = item.stringValue
      case AVMetadataKey.commonKeyAlbumName:
        data["album"] = item.stringValue
      case AVMetadataKey.commonKeyArtist:
        data["artist"] = item.stringValue
      case AVMetadataKey.commonKeyArtwork:
        data["artwork"] = item.dataValue != nil
      default:
        break
      }
    }
  }
  
  private func handleiTunes(metadata: [AVMetadataItem], data: inout [String: Any?]) {
    for item in metadata {
      switch item.key as? AVMetadataKey {
      case AVMetadataKey.iTunesMetadataKeyAlbumArtist:
        data["albumArtist"] = item.stringValue
      case AVMetadataKey.iTunesMetadataKeyUserGenre:
        data["genre"] = item.stringValue
      case AVMetadataKey.iTunesMetadataKeyPredefinedGenre:
        data["genre"] = item.stringValue
      case AVMetadataKey.iTunesMetadataKeyComposer:
        data["composer"] = item.stringValue
      case AVMetadataKey.iTunesMetadataKeyTrackNumber:
        data["track"] = item.stringValue
      case AVMetadataKey.iTunesMetadataKeyReleaseDate:
        data["date"] = item.stringValue
      default:
        break
      }
    }
  }
  
  private func handleID3(metadata: [AVMetadataItem], data: inout [String: Any?]) {
    for item in metadata {
      switch item.key as? AVMetadataKey {
      case AVMetadataKey.id3MetadataKeyComposer:
        data["composer"] = item.stringValue
      case AVMetadataKey.id3MetadataKeyTrackNumber:
        data["track"] = item.stringValue
      case AVMetadataKey.id3MetadataKeyYear:
        data["year"] = item.numberValue
      default:
        break
      }
    }
  }
}
