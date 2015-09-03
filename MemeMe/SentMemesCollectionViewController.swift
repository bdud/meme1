//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/3/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {

    // MARK: Constants

    let cellReuseId = "MemeCell"
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // MARK: Properties

    var memes: [Meme] {
        get {
            return appDelegate.memes
        }
    }

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewWillAppear(animated: Bool) {
        self.collectionView?.reloadData()
    }

}
