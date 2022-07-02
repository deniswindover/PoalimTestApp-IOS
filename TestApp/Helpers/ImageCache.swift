//
//  ImageCache.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import Foundation
import UIKit


class ImageCache {
    
    static let placeholder = UIImage(named: "placeholder")
    static let shared = ImageCache()
    private var mainFolder: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    init(){
        checkLastClearingCache()
    }
    
    func saveImageToCache(_ image: UIImage?, url: String) {
        let _url = mainFolder.appendingPathComponent(url)
        
        if !FileManager.default.fileExists(atPath: _url.path) {
            if let data = image?.pngData() {
                try? data.write(to: _url)
            }
        }
    }
    
    func imageFromCache(with url: String) -> UIImage? {

        let _url = mainFolder.appendingPathComponent(url)

        if let data = try? Data(contentsOf: _url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func checkLastClearingCache(){
        
        if let _lastClearingCache = lastClearingCache,
           Calendar.current.isDateInToday(_lastClearingCache) {
            return
        }

        DispatchQueue.main.async {
            self.clearCache()
        }
        
    }
    
    private var lastClearingCache: Date? {
        set{
            UserDefaults.standard.set(newValue, forKey: "lastClearingCache")
        }
        get{
            return UserDefaults.standard.value(forKey: "lastClearingCache") as? Date
        }
    }
    
    private func clearCache(){
        
        let cacheDirectory = mainFolder
        let properties = [URLResourceKey.localizedNameKey, URLResourceKey.creationDateKey, URLResourceKey.localizedTypeDescriptionKey]
        let filelist = try? FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: properties, options: [])
        if filelist != nil {
            for URLname in filelist! {
                let filePath = URLname.path
                let attrFile: Dictionary? = try? FileManager.default.attributesOfItem(atPath: filePath)
                let createdAt = attrFile![FileAttributeKey.creationDate] as! Date
                let createdSince = fabs( createdAt.timeIntervalSinceNow )
#if DEBUG
                print( "file created at \(createdAt), \(createdSince) seconds ago" )
#endif
                if createdSince > 86400 { // 1 day
                    let resultDelete: Bool
                    do {
                        try FileManager.default.removeItem(atPath: filePath)
                        resultDelete = true
                    } catch _ {
                        resultDelete = false
                    }
#if DEBUG
                    print("purging file =\(filePath), result= \(resultDelete)")
#endif
                }
            }
        }
        
        lastClearingCache = Date()
        
    }
    
}
