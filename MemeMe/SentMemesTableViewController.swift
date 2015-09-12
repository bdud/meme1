//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/5/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    // MARK: Properties

    let cellReuseId = "SentMemeCell"
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var memes: [Meme] {
        return appDelegate.memes
    }

    // MARK: Overrides

    override func viewWillAppear(animated: Bool) {
        // FIXME Performance: better to subscribe to data changes
        // and reload only when necessary.
        tableView.reloadData()
    }

}
