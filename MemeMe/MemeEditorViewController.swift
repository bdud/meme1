//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Bill Dawson on 8/25/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit
import AVFoundation

enum EditorMode {
    case Add, Edit
}

protocol MemeEditorDelegate {
    func memeEditor(memeEditor: MemeEditorViewController, didSaveMeme meme: Meme)
}

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: Constants

    let fontName = "HelveticaNeue-CondensedBlack"
    let fontSize: CGFloat = 40.0
    let strokeWidth: NSNumber = -3.0
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    let textFieldVerticalBuffer: CGFloat = 20.0

    // MARK: Properties

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    var delegate: MemeEditorDelegate?

    var currentImageOriginalSize: CGSize?
    var memes: [Meme] {
        get {
            return appDelegate.memes
        }
    }

    // MARK: Properties for Editing

    var mode: EditorMode = EditorMode.Add // default

    // When in .Edit mode, this is the meme being edited.
    var editingMeme: Meme?

    var dirty: Bool = false {
        didSet {
            enableBarItems()
        }
    }

    var originalLoaded: Bool = false

    // MARK: Outlets

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()

        setupTextFields()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        enableBarItems()
        subscribeToKeyboardNotifications()
        if mode == .Edit && !originalLoaded {
            originalLoaded = true
            if let originalMeme = editingMeme {
                topTextField.text = originalMeme.topText
                bottomTextField.text = originalMeme.bottomText
                replaceImage(originalMeme.originalImage)
                // The image view won't be done sizing yet, so
                // we'll wait until viewDidAppear to move the text
                // fields to their proper place.
                // To avoid the ugly flash of the text field
                // moving from one place to another, we'll hide
                // them here and then they'll be unhidden once
                // they've moved to their proper place.
                // TODO even better would be an alpha animation
                // from fully transparency to full opacity.
                // Or simply an animation of the new constraints
                // in moveTextFieldsToDisplayedImage instead of
                // hiding them and showing them -- a smooth translation
                // animation would not be as jarring as either the abrupt
                // move or the hide/show.

                topTextField.hidden = true
                bottomTextField.hidden = true
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let size = currentImageOriginalSize {
            moveTextFieldsToDisplayedImage(AVMakeRectWithAspectRatioInsideRect(size, imageView.bounds))
        }
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

    @IBAction func textFieldEditingChanged(sender: AnyObject) {
        dirty = true
    }

    func shareButtonPressed() {
        var meme = createMemedImage()

        let activityViewController = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType, completed, items, error) in
            if completed {
                // We only want to add to our "database" if the user actually went through
                // with the share.
                self.appDelegate.saveNewMeme(meme)
                self.delegate?.memeEditor(self, didSaveMeme: meme)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }

    func navbarCancelPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func navbarDonePressed() {
        if let originalMeme = editingMeme {
            let newMeme = createMemedImage()
            appDelegate.updateExistingMeme(originalMeme, withNewMeme: newMeme)
            delegate?.memeEditor(self, didSaveMeme: newMeme)
        }
        dismissViewControllerAnimated(true, completion: nil)
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
            replaceImage(image)
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

    func createMemedImage() -> Meme {

        // Don't want nav and status bars in the shared image
        showBars(false)

        var scaledImageRect: CGRect?

        func adjustTextFields() {
            if let imageSize = currentImageOriginalSize {
                scaledImageRect = AVMakeRectWithAspectRatioInsideRect(imageSize, imageView.bounds)
                moveTextFieldsToDisplayedImage(scaledImageRect!)
            }
        }

        // imageView will have resized because of hiding bars,
        // so need to move the text fields.
        adjustTextFields()

        let imageViewBackground: UIColor = imageView.backgroundColor!
        // Make it temporarily transparent for this snapshot
        imageView.backgroundColor = nil

        // Draw and capture the whole view.
        let memedImage = captureView(scaledImageRect)

        // Give imageView its background back
        imageView.backgroundColor = imageViewBackground

        showBars(true)

        // Move those text fields again now that bars are back and imageView has resized.
        adjustTextFields()

        return Meme(originalImage: imageView.image!,
            memedImage: memedImage,
            topText: topTextField.text,
            bottomText: bottomTextField.text)
    }

    func captureView(scaledImageRect: CGRect?) -> UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let imageRect = scaledImageRect {
            // Convert rect to be relative to view (not imageView)
            var cropRect = view.convertRect(imageRect, fromView: imageView)
            // Crop to just the visible portion of the image inside imageView
            image = UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, cropRect));
        }
        return image
    }

    // MARK: Miscellaneous

    func setupNavBar() {
        if (mode == .Add) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.Action,
                target: self, action: "shareButtonPressed")
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.Cancel,
                target: self, action: "navbarCancelPressed")
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.Cancel,
                target: self, action: "navbarCancelPressed")
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.Done,
                target: self, action: "navbarDonePressed")
        }
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
        if (mode == .Add) {
            // Share button
            navigationItem.leftBarButtonItem?.enabled = imageView.image != nil
        } else {
            // Done button
            navigationItem.rightBarButtonItem?.enabled = dirty
        }

    }

    func showBars(show: Bool) {
        toolbar.hidden = !show
        navigationController?.navigationBarHidden = !show
    }


    /**
        Moves the top and bottom text fields so that they are on the image, despite the image being aspect-fitted
        and thus not filling the entire image view.
    
        :param: scaledImageRect The image as scaled inside the ImageView
    */
    func moveTextFieldsToDisplayedImage(scaledImageRect: CGRect) {
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

        topTextField.hidden = false
        bottomTextField.hidden = false

    }
    
    func replaceImage(image: UIImage) {
        // We cache this because we'll need it again if we draw the image
        // to a context after hiding parts of the screen, which is what we
        // do when we share.
        currentImageOriginalSize = image.size

        if let replacedImage = imageView.image {
            // We're replacing something already in there,
            // so this makes our editing session dirty.
            dirty = true
        }

        imageView.image = image
        moveTextFieldsToDisplayedImage(AVMakeRectWithAspectRatioInsideRect(image.size, imageView.bounds))
    }
    
}

