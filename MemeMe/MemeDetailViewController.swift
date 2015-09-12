//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/10/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var meme: Meme?
    override func viewWillAppear(animated: Bool) {
        if let meme = meme {
            imageView.image = meme.memedImage
        }
    }

    // MARK: Static/Class methods
    class func pushInstanceAtopController(sourceViewController: UIViewController, withMeme meme: Meme) {
        if let controller = sourceViewController.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as? MemeDetailViewController {
            controller.meme = meme
            sourceViewController.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
