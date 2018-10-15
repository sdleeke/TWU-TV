//
//  Section.swift
//  TWU TV
//
//  Created by Steve Leeke on 10/13/18.
//  Copyright © 2018 Countryside Bible Church. All rights reserved.
//

import Foundation

class Section
{
    var strings:[String]?
    {
        willSet {
            
        }
        didSet {
            indexStrings = strings?.map({ (string:String) -> String in
                if let string = indexTransform?(string.uppercased()) {
                    return string
                } else {
                    return string.uppercased()
                }
            })
        }
    }
    
    var indexStrings:[String]?
    
    var indexTransform:((String?)->String?)? = stringWithoutPrefixes
    
    var showHeaders = false
    var showIndex = false
    
    var titles:[String]?
    var counts:[Int]?
    var indexes:[Int]?
    
    func build()
    {
        guard let indexStrings = indexStrings, strings?.count > 0 else {
            titles = nil
            counts = nil
            indexes = nil
            
            return
        }
        
        if showIndex {
            guard indexStrings.count > 0 else {
                titles = nil
                counts = nil
                indexes = nil
                
                return
            }
        }
        
        let a = "A"
        
        titles = Array(Set(indexStrings.map({ (string:String) -> String in
            if string.endIndex >= a.endIndex {
                return String(string[..<a.endIndex]).uppercased()
            } else {
                return string
            }
        })
            
        )).sorted() { $0 < $1 }
        
        if titles?.count == 0 {
            titles = nil
            counts = nil
            indexes = nil
        } else {
            var stringIndex = [String:[String]]()
            
            for indexString in indexStrings {
                if stringIndex[String(indexString[..<a.endIndex])] == nil {
                    stringIndex[String(indexString[..<a.endIndex])] = [String]()
                }
                
                stringIndex[String(indexString[..<a.endIndex])]?.append(indexString)
            }
            
            var counter = 0
            
            var counts = [Int]()
            var indexes = [Int]()
            
            for key in stringIndex.keys.sorted() {
                if let value = stringIndex[key] {
                    indexes.append(counter)
                    counts.append(value.count)
                    counter += value.count
                }
            }
            
            self.counts = counts.count > 0 ? counts : nil
            self.indexes = indexes.count > 0 ? indexes : nil
        }
    }
}
