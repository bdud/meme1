//
//  SentMemesCollectionViewController+UICollectionViewDataSource.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/3/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

extension SentMemesCollectionViewController {

    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseId, forIndexPath: indexPath) as! SentMemesCollectionViewCell

        cell.imageView.image = memes[indexPath.row].memedImage
        return cell
    }

}