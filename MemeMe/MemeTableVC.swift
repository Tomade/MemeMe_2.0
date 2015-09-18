//
//  SentMemesTableVC.swift
//  MemeMe
//
//  Created by Danilo Fiorenzano on 13/9/2015.
//  Copyright (c) 2015 Danilo Fiorenzano. All rights reserved.
//

import UIKit

class MemeTableVC: UITableViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sentMemeArray = (UIApplication.sharedApplication().delegate as! AppDelegate).savedMemes
        return sentMemeArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("sentMeme", forIndexPath: indexPath) as! UITableViewCell
        let sentMemeArray = (UIApplication.sharedApplication().delegate as! AppDelegate).savedMemes
        let meme = sentMemeArray[indexPath.row]
        cell.imageView?.image = meme.memedImage
        cell.imageView?.contentMode = .ScaleAspectFit
        cell.textLabel?.text = meme.topText + "..." + meme.bottomText
        
        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeDetail") as! MemeDetailVC
        vc.memeIndex = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
    }
}
