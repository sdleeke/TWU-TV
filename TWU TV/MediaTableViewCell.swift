//
//  MediaTableViewCell.swift
//  TWU
//
//  Created by Steve Leeke on 8/1/15.
//  Copyright (c) 2015 Steve Leeke. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell
{
    var sermon:Sermon?
    {
        willSet {
            
        }
        didSet {
            Thread.onMainThread {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SERMON_UPDATE_UI), object: oldValue)
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SERMON_UPDATE_UI), object: self.sermon)
            }
            
            updateUI()
        }
    }
    
    @objc func updateUI()
    {
        guard Thread.isMainThread else {
            return
        }

        title.text = sermon?.partString
    }
    
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
