//
//  extensions.swift
//  TWU TV
//
//  Created by Steve Leeke on 10/13/18.
//  Copyright © 2018 Countryside Bible Church. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    func setTitleTextAttributes(_ attributes:[NSAttributedStringKey:UIFont])
    {
        setTitleTextAttributes(attributes, for: UIControlState.normal)
        setTitleTextAttributes(attributes, for: UIControlState.disabled)
        setTitleTextAttributes(attributes, for: UIControlState.selected)
        setTitleTextAttributes(attributes, for: UIControlState.highlighted)
        setTitleTextAttributes(attributes, for: UIControlState.focused)
    }
}

extension UISegmentedControl {
    func setTitleTextAttributes(_ attributes:[String:UIFont])
    {
        setTitleTextAttributes(attributes, for: UIControlState.normal)
        setTitleTextAttributes(attributes, for: UIControlState.disabled)
        setTitleTextAttributes(attributes, for: UIControlState.selected)
        setTitleTextAttributes(attributes, for: UIControlState.highlighted)
        setTitleTextAttributes(attributes, for: UIControlState.focused)
    }
}

extension UIButton {
    func setTitle(_ string:String?)
    {
        setTitle(string, for: UIControlState.normal)
        setTitle(string, for: UIControlState.disabled)
        setTitle(string, for: UIControlState.selected)
        setTitle(string, for: UIControlState.highlighted)
        setTitle(string, for: UIControlState.focused)
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
            guard self != url?.lastPathComponent else {
                return cachesURL?.appendingPathComponent(self.replacingOccurrences(of: " ", with: ""))
            }
            
            return url?.fileSystemURL
        }
    }
    
//    var fileSystemURL : URL?
//    {
//        get {
//            return url?.fileSystemURL
//        }
//    }
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

fileprivate var queue = DispatchQueue(label: UUID().uuidString)

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
                return try Data(contentsOf: self)
            } catch let error {
                print("failed to delete download: \(error.localizedDescription)")
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
            print("failed to delete download: \(error.localizedDescription)")
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
            guard let imageURL = fileSystemURL else {
                return nil
            }
            
            if imageURL.exists, let image = UIImage(contentsOfFile: imageURL.path) {
                return image
            } else {
                guard let data = try? Data(contentsOf: self) else {
                    return nil
                }
                
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                DispatchQueue.global(qos: .background).async {
                    queue.sync {
                        guard !imageURL.exists else {
                            return
                        }
                        
                        do {
                            try UIImageJPEGRepresentation(image, 1.0)?.write(to: imageURL, options: [.atomic])
                            print("Image \(self.lastPathComponent) saved to file system")
                        } catch let error {
                            NSLog(error.localizedDescription)
                            print("Image \(self.lastPathComponent) not saved to file system")
                        }
                    }
                }

                return image
            }
        }
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

