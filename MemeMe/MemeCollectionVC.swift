//
//  MemeCollectionVC.swift
//  MemeMe
//
//  Created by Danilo Fiorenzano on 14/9/2015.
//  Copyright (c) 2015 Danilo Fiorenzano. All rights reserved.
//

import UIKit

let reuseIdentifier = "sentMeme"

class MemeCollectionVC: UICollectionViewController {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.minimumInteritemSpacing = 3
        flowLayout.minimumLineSpacing = 3
        let space:CGFloat = 3.0
        let dimension = (view.frame.width - (2 * space)) / 3.0
        flowLayout.itemSize = CGSizeMake(dimension, dimension)

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sentMemeArray = (UIApplication.sharedApplication().delegate as! AppDelegate).savedMemes
        return sentMemeArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
    
        // Configure the cell
        let sentMemeArray = (UIApplication.sharedApplication().delegate as! AppDelegate).savedMemes
        let meme = sentMemeArray[indexPath.item]
        cell.imageView?.image = meme.memedImage
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeDetail") as! MemeDetailVC
        vc.memeIndex = indexPath.item
        navigationController?.pushViewController(vc, animated: true)
    }
}
