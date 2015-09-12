//
//  SentMemesTableViewController+UITableViewDataSource.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/5/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

extension SentMemesTableViewController {

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            cellReuseId,
            forIndexPath: indexPath) as! SentMemesTableViewCell

        cell.meme = memes[indexPath.row];

        return cell
    }

 }
