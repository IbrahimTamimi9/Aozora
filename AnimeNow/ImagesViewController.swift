//
//  ImagesViewController.swift
//  Aozora
//
//  Created by Paul Chavarria Podoliako on 8/5/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import Foundation
import ANCommonKit
import Bolts

protocol ImagesViewControllerDelegate: class {
    func imagesViewControllerSelected(#imageURL: String)
}

public class ImagesViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    weak var delegate: ImagesViewControllerDelegate?
    var dataSource: [String] = []
    var malScrapper: MALScrapper!

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        malScrapper = MALScrapper(viewController: self)
        
        var searchBarTextField = searchBar.valueForKey("searchField") as? UITextField
        searchBarTextField?.textColor = UIColor.blackColor()
        
        searchBar.becomeFirstResponder()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var size = CGSize(width: view.bounds.size.width/2-3, height: 120)
        layout.itemSize = size
    }
    
    func findImagesWithQuery(query: String, animated: Bool) {
        malScrapper.findImagesWithQuery(query, animated: animated).continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject! in
            
            let result = task.result as! [String]
            self.dataSource = result
            self.collectionView.reloadData()
            
            return nil
        })
    }
    
    // MARK: - IBAction
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        dataSource = []
        collectionView.reloadData()
        let animated = segmentedControl.selectedSegmentIndex == 0 ? false : true
        findImagesWithQuery(searchBar.text, animated: animated)
    }
    
}

extension ImagesViewController: UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! BasicCollectionCell
        
        cell.titleimageView.setImageFrom(urlString: dataSource[indexPath.row], animated: false)
        
        return cell
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageURL = dataSource[indexPath.row]
        
        var imageController = ANParseKit.threadStoryboard().instantiateViewControllerWithIdentifier("Image") as! ImageViewController
        imageController.initWith(imageUrl: imageURL)
        imageController.delegate = self
        imageController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        presentViewController(imageController, animated: true, completion: nil)
    }
}

extension ImagesViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let animated = segmentedControl.selectedSegmentIndex == 0 ? false : true
        findImagesWithQuery(searchBar.text, animated: animated)
        view.endEditing(true)
        searchBar.enableCancelButton()
    }
    
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension ImagesViewController: ImageViewControllerDelegate {
    
    func imageViewControllerSelected(#imageURL: String) {
        delegate?.imagesViewControllerSelected(imageURL: imageURL)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}