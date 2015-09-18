//
//  MemeDetailVC.swift
//  MemeMe
//
//  Created by Danilo Fiorenzano on 14/9/2015.
//  Copyright (c) 2015 Danilo Fiorenzano. All rights reserved.
//

import UIKit

class MemeDetailVC: UIViewController {

    var memeIndex = -1
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        let sentMemeArray = (UIApplication.sharedApplication().delegate as! AppDelegate).savedMemes
        let meme = sentMemeArray[memeIndex]
        imageView.image = meme.memedImage
     }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }

    
    @IBAction func editMeme(sender: AnyObject) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("memeEditor") as! MemeEditorVC
        vc.memeIndex = memeIndex
        presentViewController(vc, animated: true, completion: nil)
    }
}
