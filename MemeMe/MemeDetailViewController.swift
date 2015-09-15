//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Bill Dawson on 9/10/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    // MARK: Static/Class methods

    class func pushInstanceAtopController(sourceViewController: UIViewController, withMeme meme: Meme) {
        if let controller = sourceViewController.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as? MemeDetailViewController {
            controller.meme = meme
            sourceViewController.navigationController?.pushViewController(controller, animated: true)
        }
    }

    // MARK: Instance properties
    
    @IBOutlet weak var imageView: UIImageView!

    var meme: Meme?

    // MARK: Overrides

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onMemeChanged:", name: AppConstants.MemeChangedNotification, object: nil)

        tabBarController?.tabBar.hidden = true
        if let meme = meme {
            imageView.image = meme.memedImage
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editAction:")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            if (id == "DetailToEditor") {
                let editorController = segue.destinationViewController.topViewController as! MemeEditorViewController
                editorController.mode = EditorMode.Edit
                editorController.editingMeme = meme
            }
        }
    }

    // MARK: Notification Observation

    func onMemeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo as? Dictionary<String, WrappedMeme> {
            if userInfo[AppConstants.OriginalMemeKey]?.unwrap() == meme {
                meme = userInfo[AppConstants.NewMemeKey]?.unwrap()
                if let meme = meme {
                    imageView.image = meme.memedImage
                } else {
                    imageView.image = nil
                }
            }
        }
    }

    // MARK: Actions

    @IBAction func trashAction(sender: AnyObject) {
        var alertController = UIAlertController(title: nil,
            message: "This Meme will be permanently deleted.",
            preferredStyle: UIAlertControllerStyle.ActionSheet)

        let defaultAction = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler: nil)
        alertController.addAction(defaultAction)

        let deletionAction = UIAlertAction(title: "Delete Meme",
            style: UIAlertActionStyle.Destructive) { (action: UIAlertAction!) -> Void in
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            delegate.deleteMeme(self.meme!)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(deletionAction)

        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func shareAction(sender: AnyObject) {
        if let meme = meme {
            presentViewController(UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil), animated: true, completion: nil)
        }
    }

    func editAction(sender: AnyObject) {
        if let editorController = storyboard?.instantiateViewControllerWithIdentifier("MemeEditor") as? MemeEditorViewController {
            editorController.mode = EditorMode.Edit
            performSegueWithIdentifier("DetailToEditor", sender: nil)
        }
    }
}
