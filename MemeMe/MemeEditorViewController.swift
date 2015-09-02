//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Bill Dawson on 8/25/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit
import AVFoundation

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: Constants

    let fontName = "HelveticaNeue-CondensedBlack"
    let fontSize: CGFloat = 40.0
    let strokeWidth: NSNumber = -3.0
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    let textFieldVerticalBuffer: CGFloat = 20.0

    // MARK: Properties
    var currentImageOriginalSize: CGSize?

    // MARK: Outlets

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavBar()

        self.setupTextFields()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.enableBarItems()
        self.subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Keyboard Handling

    func keyboardWillShow(notification: NSNotification) {
        if (self.bottomTextField.isFirstResponder()) {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if (self.bottomTextField.isFirstResponder()) {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }

    func subscribeToKeyboardNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }


    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
            return keyboardSize.CGRectValue().height
        }
        return 0.0
    }


    // MARK: Actions

    @IBAction func takePhoto(sender: AnyObject) {
        pickImageWithSourceType(UIImagePickerControllerSourceType.Camera)
    }

    @IBAction func chooseFromLibrary(sender: AnyObject) {
        pickImageWithSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
    }

    func shareButtonPressed() {
        let meme = self.save()
        let activityViewController = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

    func navbarCancelPressed() {
        reset()
    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(textField: UITextField) {
        if (topTextField == textField && textField.text == defaultTopText) || (bottomTextField == textField && textField.text == defaultBottomText)
        {
            textField.text = "";
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidEndEditing(textField: UITextField) {
        enableBarItems()
    }

    // MARK: Image Picking

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {

            self.imageView.image = image

            // We cache this because we'll need it again if we draw the image
            // to a context after hiding parts of the screen, which is what we
            // do when we share.
            currentImageOriginalSize = image.size

            moveTextFieldsToDisplayedImage(currentImageOriginalSize!)


        }
        self.dismissViewControllerAnimated(true, completion: nil)


        enableBarItems()
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        enableBarItems()
    }

    func pickImageWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        self.presentViewController(picker, animated: true, completion: nil)
    }

    // MARK: Sharing

    func save() -> Meme {
        showBars(false)

        // imageView will have resized, so need to move those text fields again!
        if let size = currentImageOriginalSize {
            moveTextFieldsToDisplayedImage(size)
        }

        let memedImage = captureView()

        showBars(true)

        // ... and back again ...
        if let size = currentImageOriginalSize {
            moveTextFieldsToDisplayedImage(size)
        }

        return Meme(originalImage: self.imageView.image!, memedImage: memedImage, topText: self.topTextField.text, bottomText: self.bottomTextField.text)
    }

    func captureView() -> UIImage {
        let view = self.view
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // MARK: Miscellaneous

    func setupNavBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action,
            target: self, action: "shareButtonPressed")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel,
            target: self, action: "navbarCancelPressed")
    }

    func setupTextFields() {
        topTextField.delegate = self
        bottomTextField.delegate = self

        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: fontName, size: fontSize)!,
            NSStrokeWidthAttributeName: strokeWidth
        ]

        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
    }

    func enableBarItems() {
        self.cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        self.navigationItem.leftBarButtonItem?.enabled = self.imageView.image != nil
        self.navigationItem.rightBarButtonItem?.enabled = self.imageView.image != nil || self.topTextField.text != defaultTopText || self.bottomTextField.text != defaultBottomText
    }

    func showBars(show: Bool) {
        self.toolbar.hidden = !show
        self.navigationController?.navigationBarHidden = !show
    }

    func moveTextFieldsToDisplayedImage(origImageSize: CGSize) {
        let scaledImageRect = AVMakeRectWithAspectRatioInsideRect(origImageSize, self.imageView.bounds)

        let parentView = self.topTextField.superview!
        let constraints = parentView.constraints()
        let imageOriginY = scaledImageRect.origin.y
        let imageHeight = scaledImageRect.size.height

        let filteredConstraints = constraints.filter() {
            if let constraint = $0 as? NSLayoutConstraint {
                return
                    (constraint.firstAttribute == NSLayoutAttribute.Top || constraint.firstAttribute == NSLayoutAttribute.Bottom)
                    &&
                    (constraint.firstItem is UITextField || constraint.secondItem is UITextField)
            }
            return false
        }

        parentView.removeConstraints(filteredConstraints)

        var newConstraint = NSLayoutConstraint(item: self.topTextField,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.imageView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: textFieldVerticalBuffer + imageOriginY)
        parentView.addConstraint(newConstraint)

        newConstraint = NSLayoutConstraint(item: self.bottomTextField,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.imageView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: -(imageOriginY + textFieldVerticalBuffer))
        parentView.addConstraint(newConstraint)

    }
    
    func reset() {
        imageView.image = nil
        topTextField.text = defaultTopText
        bottomTextField.text = defaultBottomText
        enableBarItems()
        // Pretends a perfectly fitting image is there, so the
        // text fields will move to just their buffer offsets.
        moveTextFieldsToDisplayedImage(self.imageView.bounds.size)
    }
    
}

