//
//  ResultHolder.swift
//  meta_audio
//
//  Created by Kaisei Sunaga on 2021/02/12.
//

import Foundation
import Flutter

class ResultHolder {
  init(result: @escaping FlutterResult) {
    self.result = result
  }
  
  private let result: FlutterResult
  var completed = false
  
  func success(data: Any?) {
    guard !completed else {
      return
    }
    
    result(data)
    completed = true
  }
  
  func error(code: String, message: String? = nil, details: Any? = nil) {
    guard !completed else {
      return
    }
    
    result(FlutterError(code: code, message: message, details: details))
    completed = true
  }
  
  func notImplemented() {
    guard !completed else {
      return
    }
    
    result(FlutterMethodNotImplemented)
    completed = true
  }
}
