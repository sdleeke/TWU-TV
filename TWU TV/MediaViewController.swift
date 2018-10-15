//
//  MediaViewController.swift
//  TWU
//
//  Created by Steve Leeke on 7/31/15.
//  Copyright (c) 2015 Steve Leeke. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MediaViewController : UIViewController
{
    var views : (seriesArt: UIView?, seriesDescription: UIView?)

    var actionButton:UIBarButtonItem?
    
    fileprivate func setupBodyHTML(_ series:Series?) -> String?
    {
        guard let title = series?.title else {
            return nil
        }
        
        var bodyString = "I've enjoyed the sermon series "
        
        if let url = series?.url {
            bodyString = bodyString + "<a href=\"" + url.absoluteString + "\">" + title + "</a>"
        } else {
            bodyString = bodyString + title
        }
        
        bodyString = bodyString + " by " + "Tom Pennington"
        bodyString = bodyString + " from <a href=\"http://www.thewordunleashed.org\">" + "The Word Unleashed" + "</a>"
        bodyString = bodyString + " and thought you would enjoy it as well."
        bodyString = bodyString + "</br>"
        
        return bodyString
    }
    
    fileprivate func addressStringHTML() -> String
    {
        let addressString:String = "</br>Countryside Bible Church</br>250 Countryside Ct.</br>Southlake, TX 76092</br>(817) 488-5381</br><a href=\"mailto:cbcstaff@countrysidebible.org\">cbcstaff@countrysidebible.org</a></br>www.countrysidebible.org"
        
        return addressString
    }
    
    fileprivate func addressString() -> String
    {
        let addressString:String = "\n\nCountryside Bible Church\n250 Countryside Ct.\nSouthlake, TX 76092\nPhone: (817) 488-5381\nE-mail:cbcstaff@countrysidebible.org\nWeb: www.countrysidebible.org"
        
        return addressString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var destination = segue.destination as UIViewController
        // this next if-statement makes sure the segue prepares properly even
        //   if the MVC we're seguing to is wrapped in a UINavigationController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
    }
}
