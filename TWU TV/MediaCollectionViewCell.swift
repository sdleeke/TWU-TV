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
        
        if let image = Globals.shared.images[name] {
            self.seriesArt.image = image
        } else {
            DispatchQueue.global(qos: .userInteractive).async { () -> Void in
                series.coverArt { (image:UIImage?) in
                    Globals.shared.images[name] = image

                    Thread.onMainThread {
                        if let image = image {
                            if self.series == series {
                                self.seriesArt.image = image
                            }
                        } else {
                            self.seriesArt.image = UIImage(named: "twu_logo_circle_r")
                        }
                    }
                }
            }
        }
    }
}
