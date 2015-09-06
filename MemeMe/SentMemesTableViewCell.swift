//
//  SentMemesTableViewCell.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/5/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

class SentMemesTableViewCell: UITableViewCell {

    // MARK: Outlets

    @IBOutlet weak var topTextLabel: UILabel!

    // MARK: Properties

    var meme: Meme? {
        didSet {
            println("Did set");
            if let m = meme {
                topTextLabel.text = m.topText
            }
        }
    }
}
