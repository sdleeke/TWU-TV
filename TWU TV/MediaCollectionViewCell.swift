//
//  MediaCollectionViewCell.swift
//  TWU
//
//  Created by Steve Leeke on 7/28/15.
//  Copyright (c) 2015 Steve Leeke. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var seriesArt: UIImageView!

//    var vc:MediaCollectionViewController?
    
    var series:Series? {
        willSet {
            
        }
        didSet {
            if series != oldValue {
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
        
        guard let name = series.coverArtURL?.lastPathComponent else {
            return
        }
        
        if let image = globals.images[name] {
            self.seriesArt.image = image
        } else {
            DispatchQueue.global(qos: .userInteractive).async { () -> Void in
                series.coverArt { (image:UIImage?) in
                    Thread.onMainThread {
                        if let image = image {
                            if self.series == series {
                                globals.images[name] = image
                                self.seriesArt.image = image
                            }
                        } else {
                            self.seriesArt.image = UIImage(named: "twu_logo_circle_r")
                        }
                    }
                }
            }
        }
        
//        if let series = self.series {
//            if let image = series.loadArt() {
//                seriesArt.image = image
//            } else {
//                DispatchQueue.global(qos: .background).async { () -> Void in
//                    if let image = series.fetchArt() {
//                        if self.series == series {
//                            Thread.onMainThread {
//                                self.seriesArt.image = image
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}
