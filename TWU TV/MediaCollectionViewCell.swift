//
//  MediaCollectionViewCell.swift
//  TWU
//
//  Created by Steve Leeke on 7/28/15.
//  Copyright (c) 2015 Steve Leeke. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var seriesArt: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var series:Series? {
        willSet {
            
        }
        didSet {
            if (series != oldValue) || (seriesArt.image == nil) {
                seriesArt.image = nil
                updateUI()
            }
        }
    }
    
    override var canBecomeFocused: Bool {
        get {
            return true
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if isFocused {
            seriesArt.adjustsImageWhenAncestorFocused = true
        } else {
            seriesArt.adjustsImageWhenAncestorFocused = false
        }
    }
    
    fileprivate func updateUI()
    {
        guard let series = self.series else {
            return
        }
        
//        guard let name = series.coverArtURL?.lastPathComponent else {
//            return
//        }
        
        if let image = series.coverArt?.cache {
//        if let image = Globals.shared.images[name] {
            self.seriesArt.image = image
        } else {
            Thread.onMainThread {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            }
            
            DispatchQueue.global(qos: .userInteractive).async { () -> Void in
                series.coverArt?.block { (image:UIImage?) in
                    Thread.onMainThread {
                        if let image = image {
//                            Globals.shared.images[name] = image
                            
                            // Make sure we're still in the right place.
                            if self.series == series {
                                self.seriesArt.image = image
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                            }
                        } else {
                            // Make sure we're still in the right place.
                            if self.series == series {
                                self.seriesArt.image = UIImage(named: "twu_logo_circle_r")
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                            }
                        }
                    }
                }
            }
        }
    }
}
