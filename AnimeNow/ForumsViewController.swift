//
//  ForumViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/21/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANAnimeKit

class ForumsViewController: UIViewController {
    
    var dataSource: [[(title: String, subtitle: String, board: Int)]] =
        [
            [],
            [
                ("News Discussion","Current news in anime and manga",15),
                ("Anime & Manga Recommendations","Ask the community for series recommendations or help other users looking for suggestions",16),
                ("Anime Discussion","General anime discussion that is not specific to any particular series",1),
                ("Manga Discussion","General manga discussion that is not specific to any particular series",2)
            ],
            [
                ("Introductions","New to MyAnimeList? Introduce yourself here",8),
                ("Games, Computers & Tech Support","Discuss visual novels and other video games, or ask our community a computer related question",7),
                ("Music & Entertainment","Asian music and live-action series, Western media and artists, best-selling novels, etc",10),
                ("Current Events","World headlines, the latest in science, sports competitions, and other debate topics",6),
                ("Casual Discussion","General interest topics that don't fall into one of the sub-categories above, such as community polls",11),
                ("Creative Corner","Show your creations to get help or feedback from our community. Graphics, list designs, stories; anything goes",12),
                ("MAL Contests","Our season-long anime game and other user competitions can be found here",13),
                ("Forum Games","Fun forum games are contained here",9),
            ],
            
        ]
    var titles: [String] = ["Watched Topics","Anime & Manga","General"]
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 61.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
}

extension ForumsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BoardCell") as! BasicTableCell
        
        let (title, subtitle, _) = dataSource[indexPath.section][indexPath.row]

        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! BasicTableCell
        cell.titleLabel.text = titles[section]
        return cell.contentView
    }
    
}

extension ForumsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let (_, _, board) = dataSource[indexPath.section][indexPath.row]
        let controller = ANAnimeKit.forumViewController()
        controller.board = board
        navigationController?.pushViewController(controller, animated: true)
    }
}