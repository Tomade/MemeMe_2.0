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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let sentMemeArray = (UIApplication.sharedApplication().delegate as! AppDelegate).savedMemes
        let meme = sentMemeArray[memeIndex]
        imageView.image = meme.memedImage
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
