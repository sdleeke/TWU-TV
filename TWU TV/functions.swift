//
//  seriesFunctions.swift
//  TWU
//
//  Created by Steve Leeke on 8/31/15.
//  Copyright (c) 2015 Steve Leeke. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

func userAlert(title:String?,message:String?)
{
    if (UIApplication.shared.applicationState == UIApplicationState.active) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: Constants.Cancel, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
            
        })
        alert.addAction(action)
        
        Thread.onMainThread {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

func startAudio()
{
    let audioSession: AVAudioSession  = AVAudioSession.sharedInstance()
    
    do {
        try audioSession.setCategory(AVAudioSessionCategoryPlayback)
    } catch let error as NSError {
        NSLog(error.localizedDescription)
    }
}

func documentsURL() -> URL?
{
    let fileManager = FileManager.default
    return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
}

func cachesURL() -> URL?
{
    let fileManager = FileManager.default
    return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
}

func sortSeries(_ series:[Series]?,sorting:String?) -> [Series]?
{
    guard let series = series else {
        return nil
    }
    
    guard let sorting = sorting else {
        return nil
    }
    
    var results:[Series]?
    
    switch sorting {
    case Constants.Sorting.Title_AZ:
        results = series.sorted() { $0.titleSort < $1.titleSort }
        break
    case Constants.Sorting.Title_ZA:
        results = series.sorted() { $0.titleSort > $1.titleSort }
        break
    case Constants.Sorting.Newest_to_Oldest:
        switch Constants.JSON.URL {
        case Constants.JSON.URLS.MEDIALIST_PHP:
            results = series.sorted() { $0.id > $1.id }
            
        case Constants.JSON.URLS.MEDIALIST_JSON:
            fallthrough
            
        case Constants.JSON.URLS.SERIES_JSON:
            results = series.sorted() { $0.featuredStartDate > $1.featuredStartDate }
            
        default:
            return nil
        }
        break
    case Constants.Sorting.Oldest_to_Newest:
        switch Constants.JSON.URL {
        case Constants.JSON.URLS.MEDIALIST_PHP:
            results = series.sorted() { $0.id < $1.id }
            
        case Constants.JSON.URLS.MEDIALIST_JSON:
            fallthrough
            
        case Constants.JSON.URLS.SERIES_JSON:
            results = series.sorted() { $0.featuredStartDate < $1.featuredStartDate }
            
        default:
            return nil
        }
        break
    default:
        break
    }
    
    return results
}

func alert(title:String?,message:String?)
{
    guard alert == nil else {
        return
    }
    
    guard UIApplication.shared.applicationState == UIApplicationState.active else {
        return
    }
    
    alert = UIAlertController(title:title,
                              message: message,
                              preferredStyle: UIAlertControllerStyle.alert)
    
    let action = UIAlertAction(title: Constants.Cancel, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
        alert = nil
    })
    alert.addAction(action)
    
    Thread.onMainThread {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

func bookNumberInBible(_ book:String?) -> Int?
{
    guard let book = book else {
        return nil
    }

    if let index = Constants.TESTAMENT.OLD.index(of: book) {
        return index
    }
    
    if let index = Constants.TESTAMENT.NEW.index(of: book) {
        return Constants.TESTAMENT.OLD.count + index
    }
    
    return Constants.TESTAMENT.OLD.count + Constants.TESTAMENT.NEW.count+1 // Not in the Bible.  E.g. Selected Scriptures
}

func booksFromSeries(_ series:[Series]?) -> [String]?
{
    guard let series = series else {
        return nil
    }
    
    return Array(Set(series.filter({ (series:Series) -> Bool in
        return series.book != nil
    }).map { (series:Series) -> String in
        return series.book!
    })).sorted(by: { bookNumberInBible($0) < bookNumberInBible($1) })
}

func lastNameFromName(_ name:String?) -> String?
{
    if var lastname = name {
        while let range = lastname.range(of: Constants.SINGLE_SPACE) {
            lastname = String(lastname[range.upperBound...])
        }
        return lastname
    }
    return nil
}

var alert:UIAlertController!

func networkUnavailable(_ message:String?)
{
    if (alert == nil) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
        
        alert = UIAlertController(title:Constants.Network_Error,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        
        let action = UIAlertAction(title: Constants.Cancel, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
            alert = nil
        })
        alert.addAction(action)
        
        Thread.onMainThread {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

func filesOfTypeInCache(_ fileType:String) -> [String]?
{
    guard let path = cachesURL()?.path else {
        return nil
    }

    var files = [String]()
    
    let fileManager = FileManager.default
    
    do {
        let array = try fileManager.contentsOfDirectory(atPath: path)
        
        for string in array {
            if let range = string.range(of: fileType) {
                if fileType == String(string[range.lowerBound...]) {
                    files.append(string)
                }
            }
        }
    } catch let error as NSError {
        NSLog(error.localizedDescription)
        print("failed to get files in caches directory")
    }
    
    return files.count > 0 ? files : nil
}

func stringWithoutPrefixes(_ fromString:String?) -> String?
{
    guard let fromString = fromString else {
        return nil
    }
    
    return fromString.withoutPrefixes
}

