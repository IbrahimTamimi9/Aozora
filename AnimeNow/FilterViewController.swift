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
    func finishedWith(#configuration: [(FilterSection, String?, [String])], selectedGenres: [String])
}

class FilterViewController: UIViewController {
    
    let sectionHeaderHeight: CGFloat = 44
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: FilterViewControllerDelegate?
    
    var expandedSection: Int?
    var selectedGenres: [String] = []
    var filteredDataSource: [[String]] = []
    var sectionsDataSource: [(FilterSection, String?, [String])] = []
    
    func initWith(#configuration: [(FilterSection, String?, [String])]) {
        sectionsDataSource = configuration
        for _ in sectionsDataSource {
            filteredDataSource.append([])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dimissViewControllerPressed(sender: AnyObject) {
        delegate?.finishedWith(configuration: sectionsDataSource, selectedGenres: selectedGenres)
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
        
        let (filterSection, sectionValue, _) = sectionsDataSource[indexPath.section]
        let value = filteredDataSource[indexPath.section][indexPath.row]

        cell.titleLabel.text = value
        
        if filterSection == FilterSection.Genres {
            if let index = find(selectedGenres, value) {
                cell.backgroundColor = UIColor.backgroundEvenDarker()
            } else {
                cell.backgroundColor = UIColor.backgroundDarker()
            }
        } else if let sectionValue = sectionValue where sectionValue == value {
            cell.backgroundColor = UIColor.backgroundEvenDarker()
        } else {
            cell.backgroundColor = UIColor.backgroundDarker()
        }
    
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
                    headerView.subtitleLabel.text = value + " " + FontAwesome.AngleDown.rawValue
                }
            case .FilterTitle:
                headerView.subtitleLabel.text = "Clear all"
            case .AnimeType: fallthrough
            case .Year: fallthrough
            case .Status: fallthrough
            case .Studio: fallthrough
            case .Classification: fallthrough
            case .Genres:
                if let value = value {
                    headerView.subtitleLabel.text = value + " " + FontAwesome.TimesCircle.rawValue
                } else {
                    headerView.subtitleLabel.text = FontAwesome.AngleDown.rawValue
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
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var (filterSection, value, _) = sectionsDataSource[indexPath.section]
        var string = filteredDataSource[indexPath.section][indexPath.row]
        
        switch filterSection {
        case .View: fallthrough
        case .Sort: fallthrough
        case .AnimeType: fallthrough
        case .Status: fallthrough
        case .Classification: fallthrough
        case .Studio: fallthrough
        case .Year:
            sectionsDataSource[indexPath.section].1 = string
            filteredDataSource[indexPath.section] = []
            expandedSection = nil
            collectionView.reloadData()
        case .Genres:
            if let index = find(selectedGenres, string) {
                selectedGenres.removeAtIndex(index)
            } else {
                selectedGenres.append(string)
            }
            sectionsDataSource[indexPath.section].1 = selectedGenres.count != 0 ? "\(selectedGenres.count) genres" : ""
            collectionView.reloadData()
        case .FilterTitle: break
        }
        
        
    }
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
        
        if section == 2 {
            // Do nothing
            return;
        }
        
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
    
    func headerSelectedActionButton2(cell: BasicCollectionReusableView) {
        let section = cell.section!
        
        switch section {
        case 0...1:
            // Show down-down
            headerSelectedActionButton(cell)
        case 2:
            // Clear all filters
            for index in 3...8 {
                sectionsDataSource[index].1 = nil
            }
            selectedGenres.removeAll(keepCapacity: false)
            expandedSection = nil
            collectionView.reloadData()
            return
        case 3...8:
            // Clear a filter or open drop-down
            if let value = sectionsDataSource[section].1 {
                if section == 8 {
                    selectedGenres.removeAll(keepCapacity: false)
                }
                
                sectionsDataSource[section].1 = nil
                collectionView.reloadData()
            } else {
                headerSelectedActionButton(cell)
            }
        default: break
        }
        
    }
}

extension FilterViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

