//
//  extensions.swift
//  TWU TV
//
//  Created by Steve Leeke on 10/13/18.
//  Copyright © 2018 Countryside Bible Church. All rights reserved.
//

import Foundation
import UIKit


extension Set
{
    var array: [Element]
    {
        return Array(self)
    }
}

extension Array where Element : Hashable
{
    var set: Set<Element>
    {
        return Set(self)
    }
}

extension FileManager
{
    var documentsURL : URL?
    {
        get {
            return self.urls(for: .documentDirectory, in: .userDomainMask).first
        }
    }
    
    var cachesURL : URL?
    {
        get {
            return self.urls(for: .cachesDirectory, in: .userDomainMask).first
        }
    }
}

extension UIBarButtonItem {
    func setTitleTextAttributes(_ attributes:[NSAttributedString.Key:UIFont])
    {
        setTitleTextAttributes(attributes, for: UIControl.State.normal)
        setTitleTextAttributes(attributes, for: UIControl.State.disabled)
        setTitleTextAttributes(attributes, for: UIControl.State.selected)
        setTitleTextAttributes(attributes, for: UIControl.State.highlighted)
        setTitleTextAttributes(attributes, for: UIControl.State.focused)
    }
}

extension UISegmentedControl {
    func setTitleTextAttributes(_ attributes:[NSAttributedString.Key:Any])
    {
        setTitleTextAttributes(attributes, for: UIControl.State.normal)
        setTitleTextAttributes(attributes, for: UIControl.State.disabled)
        setTitleTextAttributes(attributes, for: UIControl.State.selected)
        setTitleTextAttributes(attributes, for: UIControl.State.highlighted)
        setTitleTextAttributes(attributes, for: UIControl.State.focused)
    }
}

extension UIButton {
    func setTitle(_ string:String?)
    {
        setTitle(string, for: UIControl.State.normal)
        setTitle(string, for: UIControl.State.disabled)
        setTitle(string, for: UIControl.State.selected)
        setTitle(string, for: UIControl.State.highlighted)
        setTitle(string, for: UIControl.State.focused)
    }
}

extension Thread {
    static func onMainThread(block:(()->(Void))?)
    {
        if Thread.isMainThread {
            block?()
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                block?()
            })
        }
    }
}

extension String
{
    var url : URL?
    {
        get {
            return URL(string: self)
        }
    }
    
    var fileSystemURL : URL?
    {
        get {
            guard !self.isEmpty else {
                return nil
                
            }
            
            guard url != nil else {
                if let lastPathComponent = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
                    return FileManager.default.cachesURL?.appendingPathComponent(lastPathComponent)
                } else {
                    return nil
                }
            }
            
            guard self != url?.lastPathComponent else {
                if let lastPathComponent = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) {
                    return FileManager.default.cachesURL?.appendingPathComponent(lastPathComponent)
                } else {
                    return nil
                }
            }
            
            return url?.fileSystemURL
        }
    }
}

extension Double {
    var secondsToHMS : String?
    {
        get {
            let hours = max(Int(self / (60*60)),0)
            let mins = max(Int((self - (Double(hours) * 60*60)) / 60),0)
            let sec = max(Int(self.truncatingRemainder(dividingBy: 60)),0)
            
            var string:String
            
            if (hours > 0) {
                string = "\(String(format: "%d",hours)):"
            } else {
                string = Constants.EMPTY_STRING
            }
            
            string += "\(String(format: "%02d",mins)):\(String(format: "%02d",sec))"
            
            return string
        }
    }
}

extension String
{
    var withoutPrefixes : String
    {
        get {
            var sortString = self
            
            let quote:String = "\""
            let prefixes = ["A ","An ","And ","The "]
            
            if self.endIndex >= quote.endIndex, String(self[..<quote.endIndex]) == quote {
                sortString = String(self[quote.endIndex...])
            }
            
            for prefix in prefixes {
                if self.endIndex >= prefix.endIndex, String(self[..<prefix.endIndex]) == prefix {
                    sortString = String(self[prefix.endIndex...])
                    break
                }
            }
            
            return sortString
        }
    }
    
    var hmsToSeconds : Double?
    {
        get {
            guard self.range(of: ":") != nil else {
                return nil
            }
            
            var str = self.replacingOccurrences(of: ",", with: ".")
            
            var numbers = [Double]()
            
            repeat {
                if let index = str.range(of: ":") {
                    let numberString = String(str[..<index.lowerBound])
                    
                    if let number = Double(numberString) {
                        numbers.append(number)
                    }
                    
                    str = String(str[index.upperBound...])
                }
            } while str.range(of: ":") != nil
            
            if !str.isEmpty {
                if let number = Double(str) {
                    numbers.append(number)
                }
            }
            
            var seconds = 0.0
            var counter = 0.0
            
            for number in numbers.reversed() {
                seconds = seconds + (counter != 0 ? number * pow(60.0,counter) : number)
                counter += 1
            }
            
            return seconds
        }
    }
    
    var secondsToHMS : String?
    {
        get {
            guard let timeNow = Double(self) else {
                return nil
            }
            
            let hours = max(Int(timeNow / (60*60)),0)
            let mins = max(Int((timeNow - (Double(hours) * 60*60)) / 60),0)
            let sec = max(Int(timeNow.truncatingRemainder(dividingBy: 60)),0)
            let fraction = timeNow - Double(Int(timeNow))
            
            var hms:String
            
            if (hours > 0) {
                hms = "\(String(format: "%02d",hours)):"
            } else {
                hms = "00:" //Constants.EMPTY_STRING
            }
            
            // \(String(format: "%.3f",fraction)
            // .trimmingCharacters(in: CharacterSet(charactersIn: "0."))
            
            hms = hms + "\(String(format: "%02d",mins)):\(String(format: "%02d",sec)).\(String(format: "%03d",Int(fraction * 1000)))"
            
            return hms
        }
    }

    func highlighted(_ searchText:String?) -> NSAttributedString
    {
        guard let searchText = searchText else {
            return NSAttributedString(string: self, attributes: Constants.Fonts.Attributes.headline)
        }
        
        guard let range = self.lowercased().range(of: searchText.lowercased()) else {
            return NSAttributedString(string: self, attributes: Constants.Fonts.Attributes.headline)
        }
        
        let highlightedString = NSMutableAttributedString()
        
        let before = String(self[..<range.lowerBound])
        let string = String(self[range])
        let after = String(self[range.upperBound...])
        
        highlightedString.append(NSAttributedString(string: before,   attributes: Constants.Fonts.Attributes.headline))
        highlightedString.append(NSAttributedString(string: string,   attributes: Constants.Fonts.Attributes.headlineHighlighted))
        highlightedString.append(NSAttributedString(string: after,   attributes: Constants.Fonts.Attributes.headline))
        
        return highlightedString
    }
}

extension String
{
    var bookNumberInBible : Int?
    {
//        guard let book = book else {
//            return nil
//        }

        let book = self
        
        if let index = Constants.TESTAMENT.OLD.firstIndex(of: book) {
            return index
        }
        
        if let index = Constants.TESTAMENT.NEW.firstIndex(of: book) {
            return Constants.TESTAMENT.OLD.count + index
        }
        
        return Constants.TESTAMENT.OLD.count + Constants.TESTAMENT.NEW.count+1 // Not in the Bible.  E.g. Selected Scriptures
    }
    
    var lastName : String?
    {
        var lastname = self
        
        while let range = lastname.range(of: Constants.SINGLE_SPACE) {
            lastname = String(lastname[range.upperBound...])
        }
        
        return !lastname.isEmpty ? lastname : nil
    }
}

extension URL
{
    var fileSystemURL : URL?
    {
        return self.lastPathComponent.fileSystemURL
    }
    
    var exists : Bool
    {
        get {
            if let fileSystemURL = fileSystemURL {
                return FileManager.default.fileExists(atPath: fileSystemURL.path)
            } else {
                return false
            }
        }
    }
    
    var data : Data?
    {
        get {
            do {
                let data = try Data(contentsOf: self)
                print("Data read from \(self.absoluteString)")
                return data
            } catch let error {
                NSLog(error.localizedDescription)
                print("Data not read from \(self.absoluteString)")
                return nil
            }
        }
    }
    
    func delete()
    {
        guard let fileSystemURL = fileSystemURL else {
            return
        }

        // Check if file exists and if so, delete it.

        guard FileManager.default.fileExists(atPath: fileSystemURL.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: fileSystemURL)
        } catch let error {
            print("failed to delete file at \(self.absoluteString): \(error.localizedDescription)")
        }
    }
    
    func image(block:((UIImage)->()))
    {
        if let image = image {
            block(image)
        }
    }
    
    var image : UIImage?
    {
        get {
            guard let data = data else {
                return nil
            }
            
            return UIImage(data: data)
        }
    }
}

extension UIImage
{
    func save(to url: URL?) -> UIImage?
    {
        guard let url = url else {
            return nil
        }
        
        do {
            try self.jpegData(compressionQuality: 1.0)?.write(to: url, options: [.atomic])
            print("Image saved to \(url.absoluteString)")
        } catch let error {
            NSLog(error.localizedDescription)
            print("Image not saved to \(url.absoluteString)")
        }
        
        return self
    }
}

extension Data
{
    func save(to url: URL?)
    {
        guard let url = url else {
            return
        }
        
        do {
            try self.write(to: url)
        } catch let error {
            NSLog("Data write error: \(url.absoluteString)",error.localizedDescription)
        }
    }
    
    var json : Any?
    {
        get {
            do {
                let json = try JSONSerialization.jsonObject(with: self, options: [])
                return json
            } catch let error {
                NSLog("JSONSerialization error", error.localizedDescription)
                return nil
            }
        }
    }
    
    var html2AttributedString: NSAttributedString?
    {
        get {
            do {
                return try NSAttributedString(data: self, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf16.rawValue], documentAttributes: nil)
            } catch {
                print("error:", error)
                return  nil
            }
        }
    }
    
    var html2String: String?
    {
        get {
            return html2AttributedString?.string
        }
    }
    
    var image : UIImage?
    {
        get {
            return UIImage(data: self)
        }
    }
}

extension Date
{
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MM/dd/yyyy"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let d = dateStringFormatter.date(from: dateString) {
            self = Date(timeInterval:0, since:d)
        } else {
            self = Date()
        }
    }
    
    func isNewerThanDate(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isNewer = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending
        {
            isNewer = true
        }
        
        //Return Result
        return isNewer
    }
    
    
    func isOlderThanDate(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isOlder = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isOlder = true
        }
        
        //Return Result
        return isOlder
    }
    
    func addDays(_ daysToAdd : Int) -> Date
    {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(_ hoursToAdd : Int) -> Date
    {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

extension Array where Element == Series
{
    func sort(sorting:String?) -> [Series]?
    {
//        guard let series = series else {
//            return nil
//        }

        let series = self
        
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
            results = series.sorted() { $0.featuredStartDate > $1.featuredStartDate }
            //        switch Constants.JSON.URL {
            //        case Constants.JSON.URLS.MEDIALIST_PHP:
            //            results = series.sorted() { $0.id > $1.id }
            //
            //        case Constants.JSON.URLS.MEDIALIST_JSON:
            //            fallthrough
            //
            //        case Constants.JSON.URLS.SERIES_JSON:
            //            results = series.sorted() { $0.featuredStartDate > $1.featuredStartDate }
            //
            //        default:
            //            return nil
            //        }
            break
        case Constants.Sorting.Oldest_to_Newest:
            results = series.sorted() { $0.featuredStartDate < $1.featuredStartDate }
            //        switch Constants.JSON.URL {
            //        case Constants.JSON.URLS.MEDIALIST_PHP:
            //            results = series.sorted() { $0.id < $1.id }
            //
            //        case Constants.JSON.URLS.MEDIALIST_JSON:
            //            fallthrough
            //
            //        case Constants.JSON.URLS.SERIES_JSON:
            //            results = series.sorted() { $0.featuredStartDate < $1.featuredStartDate }
            //
            //        default:
            //            return nil
            //        }
            break
        default:
            break
        }
        
        return results
    }

    var books : [String]?
    {
//        guard let series = series else {
//            return nil
//        }
        
        return self.filter({ (series:Series) -> Bool in
            return series.book != nil
        }).map({ (series:Series) -> String in
            return series.book!
        }).set.array.sorted(by: { $0.bookNumberInBible < $1.bookNumberInBible })
    }
}
