//
//  FilterViewController.swift
//  AnimeNow
//
//  Created by Paul Chavarria Podoliako on 6/25/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

import UIKit
import ANCommonKit
import ANParseKit

enum FilterSection: String {
    case View = "View"
    case Sort = "Sort"
    case FilterTitle = "Filter"
    case AnimeType = "Type"
    case Year = "Year"
    case Status = "Status"
    case Studio = "Studio"
    case Classification = "Classification"
    case Genres = "Genres"
    
}

enum SortBy: String {
    case Rating = "Rating"
    case Popularity = "Popularity"
    case Title = "Title"
    case NextAiringEpisode = "Next Airing Episode"
    case None = "None"
    
    static func allRawValues() -> [String] {
        return [
            SortBy.Rating.rawValue,
            SortBy.Popularity.rawValue,
            SortBy.Title.rawValue,
            SortBy.NextAiringEpisode.rawValue
        ]
    }
}

enum ViewType: String {
    case Chart = "Chart"
    case List = "List"
    case Poster = "Poster"
    case SeasonalChart = "SeasonalChart"
    
    static func allRawValues() -> [String] {
        return [
            ViewType.Chart.rawValue,
            ViewType.List.rawValue,
            ViewType.Poster.rawValue
        ]
    }
}

protocol FilterViewControllerDelegate: class {
    func finishedWith(#configuration: [(FilterSection, String?)], selectedGenres: [String])
}

class FilterViewController: UIViewController {
    
    let sectionHeaderHeight: CGFloat = 44
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: FilterViewControllerDelegate?
    
    var expandedSection: Int?
    var filteredDataSource: [[String]] = []
    var sectionsDataSource: [(FilterSection, String?, [String])] = [] {
        didSet {
            for _ in sectionsDataSource {
                filteredDataSource.append([])
            }
        }
    }
    
    func initWithDataSource(dataSource: [(FilterSection, String?, [String])]) {
        self.sectionsDataSource = dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 44)
        
        collectionView.reloadData()
    }
    
    @IBAction func dimissViewControllerPressed(sender: AnyObject) {
        //delegate?.finishedWith(configuration: <#[(FilterSection, String)]#>, selectedGenres: <#[String]#>)
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension FilterViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return filteredDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredDataSource[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BasicCollectionCell", forIndexPath: indexPath) as! BasicCollectionCell
        
        let value = filteredDataSource[indexPath.section][indexPath.row]

        cell.titleLabel.text = value
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            
            var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! BasicCollectionReusableView
            
            let (filterSection, value, _) = sectionsDataSource[indexPath.section]
            
            headerView.titleImageView.image = nil
            headerView.titleLabel.text = filterSection.rawValue
            headerView.delegate = self
            headerView.section = indexPath.section
            
            
            // Image
            switch filterSection {
            case .View:
                if let image = UIImage(named: "icon-view") {
                    headerView.titleImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
                }
            case .Sort:
                if let image = UIImage(named: "icon-sort") {
                    headerView.titleImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
                }
            case .FilterTitle:
                if let image = UIImage(named: "icon-filter") {
                    headerView.titleImageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
                }
            default:
                break
            }
            
            // Value
            switch filterSection {
            case .View: fallthrough
            case .Sort:
                if let value = value {
                    headerView.actionButton.setTitle(value + " " + FontAwesome.AngleDown.rawValue, forState: .Normal)
                }
            case .FilterTitle:
                headerView.actionButton.setTitle("Clear all", forState: .Normal)
            case .AnimeType: fallthrough
            case .Year: fallthrough
            case .Status: fallthrough
            case .Studio: fallthrough
            case .Classification: fallthrough
            case .Genres:
                if let value = value {
                    headerView.actionButton.setTitle(value + " " + FontAwesome.TimesCircle.rawValue, forState: .Normal)
                } else {
                    headerView.actionButton.setTitle(FontAwesome.AngleDown.rawValue, forState: .Normal)
                }
            }
            
            reusableView = headerView;
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.bounds.size.width, height: sectionHeaderHeight)
    }
}

extension FilterViewController: UICollectionViewDelegate {
    
}

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let (filterSection, value, _) = sectionsDataSource[indexPath.section]
        
        switch filterSection {
        case .View: fallthrough
        case .Sort: fallthrough
        case .FilterTitle: fallthrough
        case .AnimeType: fallthrough
        case .Status: fallthrough
        case .Classification:
            return CGSize(width: (view.bounds.size.width-23), height: sectionHeaderHeight)
        case .Studio:
            return CGSize(width: (view.bounds.size.width-23-1)/2, height: sectionHeaderHeight)
        case .Year:
            return CGSize(width: (view.bounds.size.width-23-4)/5, height: sectionHeaderHeight)
        case .Genres:
            return CGSize(width: (view.bounds.size.width-23-2)/3, height: sectionHeaderHeight)
        }
    }
}


extension FilterViewController: BasicCollectionReusableViewDelegate {
    func headerSelectedActionButton(cell: BasicCollectionReusableView) {
        
        let section = cell.section!
        
        if let expandedSection = expandedSection {
            filteredDataSource[expandedSection] = []
        }
        
        if section != expandedSection {
            expandedSection = section
            filteredDataSource[section] = sectionsDataSource[section].2
        } else {
            expandedSection = nil
        }
        
        collectionView.reloadData()
    }
}

extension FilterViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

extension FilterViewController: DropDownListDelegate {
    func selectedAction(sender: UIView, action: String, indexPath: NSIndexPath) {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    func willDismiss() {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

