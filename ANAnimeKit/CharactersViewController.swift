//
//  CharactersViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/12/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit

extension CharactersViewController: StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool {
        return false
    }
    func updateCanHideStatusBar(canHide: Bool) {
    }
}

enum CharacterSection: Int {
    case Character = 0
    case Cast
    
    static var allSections: [CharacterSection] = [.Character,.Cast]
}

public class CharactersViewController: AnimeBaseViewController {

    let HeaderCellHeight: CGFloat = 39
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}


extension CharactersViewController: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CharacterSection.allSections.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        switch CharacterSection(rawValue: section)! {
        case .Character: numberOfRows = anime.characters.characters.count
        case .Cast: numberOfRows = anime.cast.cast.count
        }
        
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch CharacterSection(rawValue: indexPath.section)! {
        case .Character:
            let cell = tableView.dequeueReusableCellWithIdentifier("CharacterCell") as! CharacterCell
            let character = anime.characters.characterAtIndex(indexPath.row)
            cell.characterImageView.setImageFrom(urlString: character.image, animated:true)
            cell.characterName.text = character.name
            cell.characterRole.text = character.role
            if let japaneseVoiceActor = character.japaneseActor {
                cell.personImageView.setImageFrom(urlString: japaneseVoiceActor.image, animated:true)
                cell.personName.text = japaneseVoiceActor.name
                cell.personJob.text = japaneseVoiceActor.job
            } else {
                cell.personImageView.image = nil
                cell.personName.text = ""
                cell.personJob.text = ""
            }
            
            cell.layoutIfNeeded()
            return cell
        case .Cast:
            let cell = tableView.dequeueReusableCellWithIdentifier("CastCell") as! CharacterCell
            let cast = anime.cast.castAtIndex(indexPath.row)
            cell.personImageView.setImageFrom(urlString: cast.image)
            cell.personName.text = cast.name
            cell.personJob.text = cast.job
            cell.layoutIfNeeded()
            return cell
        }
        
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell") as! TitleCell
        var title = ""
        
        switch CharacterSection(rawValue: section)! {
        case .Character:
            title = "Characters"
        case .Cast:
            title = "Cast"
        }
        
        cell.titleLabel.text = title
        return cell.contentView
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? HeaderCellHeight : 0
    }
}

extension CharactersViewController: UITableViewDelegate {
    
}

   