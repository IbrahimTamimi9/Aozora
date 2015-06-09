//
//  AnimeInformationViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/9/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import Shimmer
import ANCommonKit

class AnimeInformationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shimeringView: FBShimmeringView!
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var openInAnimeTrakr: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shimeringView.contentView = animeTitle
        shimeringView.shimmering = true
        
        openInAnimeTrakr.layer.borderColor = UIColor.belizeHole().CGColor
        openInAnimeTrakr.layer.borderWidth = 2.0
        openInAnimeTrakr.layer.cornerRadius = 2.0
        openInAnimeTrakr.layer.backgroundColor = UIColor.peterRiver().CGColor
    }
}

extension AnimeInformationViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("SypnosisCell") as! BasicTableCell
            return cell
        default:
            break;
        }
        
        return UITableViewCell()
    }
}

extension AnimeInformationViewController: UITableViewDelegate {
    
}