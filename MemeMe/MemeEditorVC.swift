//
//  ViewController.swift
//  MemeMe
//
//  Created by Danilo Fiorenzano on 22/8/2015.
//  Copyright (c) 2015 Danilo Fiorenzano. All rights reserved.
//

/*
  This is the view controller for MemeMe 2.0.  In addition to satisfying the
original requirements, it also implements zoom/pan with standard gestures by
means of a UIScrollView embedding the UIIMageView.  Pictures are initially 
placed inside the scroll view by programmatically changing the autolayout 
constraints between the UIIMageView and the UIScrollView.

  We also use the "Cancel" button visible in the screen demo but absent in the
rubric to abort the edit operation.

*/


import UIKit

class MemeEditorVC: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var memeIndex = -1
    var meme:Meme?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!

    @IBOutlet weak var northBar: UIToolbar!
    @IBOutlet weak var southBar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var memeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if memeIndex >= 0 {
            meme = (UIApplication.sharedApplication().delegate as! AppDelegate).savedMemes[memeIndex]
            topTextField.text = meme!.topText
            bottomTextField.text = meme!.bottomText
            imageView.image = meme!.image
            
        }
        else {
            // new meme
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            shareButton.enabled = false
        }

        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : "-2.0"
        ]
        
        for field in [topTextField, bottomTextField] {
            field.defaultTextAttributes = memeTextAttributes
            field.textAlignment = .Center
            field.delegate = self
        }
        scrollView.delegate = self

    }

    override func viewDidLayoutSubviews() {
        if memeIndex > -1 {
            updateMinZoom()
            scrollView.zoomScale = meme!.zoomScale
            scrollView.contentOffset = meme!.imageOffset
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateConstraints()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    

    // No status bar, more room for content
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // cancel button
    @IBAction func startOver(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // handle orientation transitions
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: { _ in
            self.updateMinZoom()
            self.updateConstraints()
        })
    }

    // Zoom to show as much image as possible unless image is smaller than screen
    func updateMinZoom() {
        if let image = imageView.image {
            var minZoom = min(scrollView.bounds.size.width / image.size.width,
                scrollView.bounds.size.height / image.size.height)
            minZoom = min(1, minZoom)
            scrollView.minimumZoomScale = minZoom
        }
    }

    
    // dynamically reconfigure constraints to keep picture centered
    func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            // center image if it is smaller than screen
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
        }
    }

    
    // MARK: UIScrollViewDelegate methods
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }


    // MARK: Textfield delegate methods
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // clear textfield content first if holding default placeholder text
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var s = textField.text as NSString!
        s = s.stringByReplacingCharactersInRange(range, withString: string)
        // ensure UPPERCASE text, even if automatically pasted from a predictive keyboard
        textField.text = s.uppercaseString
        return false
    }
    
    
    
    // MARK: Image picker methods
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
  
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = img
            imageView.sizeToFit()
            updateMinZoom()
            scrollView.zoomScale = scrollView.minimumZoomScale
            shareButton.enabled = true
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    // MARK: Keyboard/view handling
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        // discount bottom bar height, as it's not needed while typing and OK to overlap
        return keyboardSize.CGRectValue().height - southBar.frame.size.height
    }


    // MARK: share methods
    @IBAction func shareMeme(sender: AnyObject) {
        func generateMemedImage() -> UIImage {
            // Render view to an image
            UIGraphicsBeginImageContext(memeView.frame.size)
            memeView.drawViewHierarchyInRect(memeView.frame, afterScreenUpdates: true)
            let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return memedImage
        }
      
        let memedImage = generateMemedImage()
        let actionController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        actionController.completionWithItemsHandler = { (_, completed: Bool, _, _) in
            if completed {
                // make/save meme object here if action successfully completed
                var meme = Meme(topText: self.topTextField.text,
                    bottomText: self.bottomTextField.text,
                    image: self.imageView.image!,
                    memedImage: memedImage,
                    zoomScale: self.scrollView.zoomScale,
                    imageOffset: self.scrollView.contentOffset)
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if self.memeIndex == -1 { // this is a new meme
                    delegate.savedMemes.append(meme)
                }
                else {
                    delegate.savedMemes[self.memeIndex] = meme
                }
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        presentViewController(actionController, animated: true, completion: nil)        
    }
}

// EOF