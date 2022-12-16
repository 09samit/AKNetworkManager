//
//  File.swift
//  AKNetworkManager
//
//  Created by Amit Garg on 15/12/22.
//

import Foundation

extension String {
    public func isImage() -> Bool {
      let imageFormats = ["jpg", "jpeg", "png", "gif"]
      
      if let ext = self.getExtension() {
        return imageFormats.contains(ext)
      }
      
      return false
    }
    
    public func isVideo() -> Bool {
      let imageFormats = ["mp4", "m4a", "m4v", "f4v", "f4a", "m4b", "m4r", "f4b", "mov", "wmv", "wma", "avi"]
      
      if let ext = self.getVideoExtension() {
        return imageFormats.contains(ext)
      }
      
      return false
    }
    
      static func generateFileName(ForExtension extenison:String) -> String {
          let currentTimeStamp = Int(Date().timeIntervalSince1970)
          let fileName = "media_\(currentTimeStamp).\(extenison)"
          return fileName
      }
      
    public func getExtension() -> String? {
      let ext = (self as NSString).pathExtension
      
      if ext.isEmpty {
        return nil
      }
      
      return ext
    }
    
    public func getVideoExtension() -> String? {
      let ext = (self.lowercased() as NSString).pathExtension
      
      if ext.isEmpty {
        return nil
      }
      
      return ext
    }
}
