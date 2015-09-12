//
//  SentMemesCollectionViewController+UICollectionViewDelegate.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/12/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

extension SentMemesCollectionViewController {

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        MemeDetailViewController.pushInstanceAtopController(self, withMeme: memes[indexPath.row])
    }
}
