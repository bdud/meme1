//
//  SentMemesTableViewController+UITableViewDelegate.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/12/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

extension SentMemesTableViewController {

    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        MemeDetailViewController.pushInstanceAtopController(self, withMeme: memes[indexPath.row])
    }
}
