//
//  AudioParser.swift
//  meta_audio
//
//  Created by Kaisei Sunaga on 2021/02/12.
//

import Foundation

protocol AudioParser {
  func getMetadata(path: String) -> [String: Any?]
  func getArtwork(path: String) -> Data?
}
