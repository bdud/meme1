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
    var memes: [Meme]!

    // MARK: Outlets

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes

        setupNavBar()

        setupTextFields()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        enableBarItems()
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    // MARK: Keyboard Handling

    func keyboardWillShow(notification: NSNotification) {
        if (bottomTextField.isFirstResponder()) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if (bottomTextField.isFirstResponder()) {
            view.frame.origin.y += getKeyboardHeight(notification)
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
        let meme = save()
        // Really twice? (arrays are value types in Swift)
        memes.append(meme)
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)

        let activityViewController = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }

    func navbarCancelPressed() {
        reset()
    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(textField: UITextField) {
        if (topTextField == textField && textField.text == defaultTopText) ||
            (bottomTextField == textField && textField.text == defaultBottomText)
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

            imageView.image = image

            // We cache this because we'll need it again if we draw the image
            // to a context after hiding parts of the screen, which is what we
            // do when we share.
            currentImageOriginalSize = image.size

            moveTextFieldsToDisplayedImage(currentImageOriginalSize!)


        }
        dismissViewControllerAnimated(true, completion: nil)


        enableBarItems()
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        enableBarItems()
    }

    func pickImageWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        presentViewController(picker, animated: true, completion: nil)
    }

    // MARK: Sharing

    func save() -> Meme {

        // Don't want nav and status bars in the shared image
        showBars(false)

        // imageView will have resized, so need to move those text fields again!
        if let size = currentImageOriginalSize {
            moveTextFieldsToDisplayedImage(size)
        }

        let imageViewBackground: UIColor = imageView.backgroundColor!
        // Make it temporarily transparent for this snapshot
        imageView.backgroundColor = nil

        // Draw and capture the whole view.
        let memedImage = captureView()

        // Give imageView its background back
        imageView.backgroundColor = imageViewBackground

        showBars(true)

        // Move those text fields again now that bars are back and imageView has resized.
        if let size = currentImageOriginalSize {
            moveTextFieldsToDisplayedImage(size)
        }

        return Meme(originalImage: imageView.image!,
            memedImage: memedImage,
            topText: topTextField.text,
            bottomText: bottomTextField.text)
    }

    func captureView() -> UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // MARK: Miscellaneous

    func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Action,
            target: self, action: "shareButtonPressed")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Cancel,
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
        cameraButton.enabled =
            UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        navigationItem.leftBarButtonItem?.enabled = imageView.image != nil
        navigationItem.rightBarButtonItem?.enabled = imageView.image != nil
            || topTextField.text != defaultTopText
            || bottomTextField.text != defaultBottomText
    }

    func showBars(show: Bool) {
        toolbar.hidden = !show
        navigationController?.navigationBarHidden = !show
    }


    /**
        Moves the top and bottom text fields so that they are on the image, despite the image being aspect-fitted
        and thus not filling the entire image view.
    
        Makes use of AVFoundation's AVMakeRectWithAspectRatioInsideRect thanks to helpful material at these
        locations:

        - https://discussions.udacity.com/t/best-way-to-position-textfields-in-mememe/10251/33?u=bill_103992
        - http://nshipster.com/image-resizing/
    
        :param: origImageSize The size of the original image from album/camera.
    */
    func moveTextFieldsToDisplayedImage(origImageSize: CGSize) {
        let scaledImageRect = AVMakeRectWithAspectRatioInsideRect(origImageSize, imageView.bounds)

        let parentView = topTextField.superview!
        let constraints = parentView.constraints()
        let imageOriginY = scaledImageRect.origin.y
        let imageHeight = scaledImageRect.size.height

        let filteredConstraints = constraints.filter() {
            if let constraint = $0 as? NSLayoutConstraint {
                return
                    (constraint.firstAttribute == NSLayoutAttribute.Top
                        || constraint.firstAttribute == NSLayoutAttribute.Bottom)
                    &&
                    (constraint.firstItem is UITextField
                        || constraint.secondItem is UITextField)
            }
            return false
        }

        parentView.removeConstraints(filteredConstraints)

        var newConstraint = NSLayoutConstraint(item: topTextField,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: imageView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: textFieldVerticalBuffer + imageOriginY)
        parentView.addConstraint(newConstraint)

        newConstraint = NSLayoutConstraint(item: bottomTextField,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: imageView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: -(imageOriginY + textFieldVerticalBuffer))
        parentView.addConstraint(newConstraint)

        parentView.updateConstraintsIfNeeded()

    }
    
    func reset() {
        imageView.image = nil
        topTextField.text = defaultTopText
        bottomTextField.text = defaultBottomText
        enableBarItems()
        // Pretends a perfectly fitting image is there, so the
        // text fields will move to just their buffer offsets.
        moveTextFieldsToDisplayedImage(imageView.bounds.size)
    }
    
}

