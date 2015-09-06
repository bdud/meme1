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
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var memeText: UILabel!

    // MARK: Properties

    var meme: Meme? {
        didSet {
            if let m = meme {
                memeText.text = "\(m.topText)…\(m.bottomText)"
                memeImageView.image = m.memedImage
            }
        }
    }
}
