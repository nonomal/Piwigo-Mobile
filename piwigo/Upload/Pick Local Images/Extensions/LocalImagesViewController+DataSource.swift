//
//  LocalImagesViewController+DataSource.swift
//  piwigo
//
//  Created by Eddy Lelièvre-Berna on 16/03/2024.
//  Copyright © 2024 Piwigo.org. All rights reserved.
//

import Photos
import UIKit
import piwigoKit

// MARK: UICollectionViewDataSource Methods
extension LocalImagesViewController: UICollectionViewDataSource
{
    // MARK: - Headers & Footers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // Header with place name
        if kind == UICollectionView.elementKindSectionHeader {
            // Images sorted by month, week or day
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "LocalImagesHeaderReusableView", for: indexPath) as? LocalImagesHeaderReusableView else {
                let view = UICollectionReusableView(frame: CGRect.zero)
                return view
            }
            
            // Determine place names from first and last images
            var imagesInSection: [PHAsset] = []
            let nberOfImageInSection = collectionView.numberOfItems(inSection: indexPath.section)
            if nberOfImageInSection <= 10 {
                // Collect all images
                for item in 0..<min(nberOfImageInSection, 10) {
                    autoreleasepool {
                        let index = getImageIndex(for: IndexPath(item: item, section: indexPath.section))
                        imagesInSection.append(fetchedImages[index])
                    }
                }
            } else {
                // Collect first 10 images
                for item in 0..<10 {
                    autoreleasepool {
                        let index = getImageIndex(for: IndexPath(item: item, section: indexPath.section))
                        imagesInSection.append(fetchedImages[index])
                    }
                }
                for item in (nberOfImageInSection - 10)..<nberOfImageInSection {
                    autoreleasepool {
                        let index = getImageIndex(for: IndexPath(item: item, section: indexPath.section))
                        imagesInSection.append(fetchedImages[index])
                    }
                }
            }
            
            let selectState = updateSelectButton(ofSection: indexPath.section)
            header.configure(with: imagesInSection, section: indexPath.section, selectState: selectState)
            header.headerDelegate = self
            return header
        }
        else if kind == UICollectionView.elementKindSectionFooter {
            // Footer with number of images
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LocalImagesFooterReusableView", for: indexPath) as? LocalImagesFooterReusableView else {
                let view = UICollectionReusableView(frame: CGRect.zero)
                return view
            }
            footer.configure(with: localImagesCollection.numberOfItems(inSection: indexPath.section))
            return footer
        }
        
        let view = UICollectionReusableView(frame: CGRect.zero)
        return view
    }
    
    
    // MARK: - Sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Number of sections depends on image sort type
        switch sortType {
        case .month:
            return indexOfImageSortedByMonth.count
        case .week:
            return indexOfImageSortedByWeek.count
        case .day:
            return indexOfImageSortedByDay.count
        case .none:
            return 1
        }
    }
    
    
    // MARK: - Items i.e. Images
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Number of items depends on image sort type and date order
        switch sortType {
        case .month:
            switch UploadVars.shared.localImagesSort {
            case .dateCreatedDescending:
                return indexOfImageSortedByMonth[section].count
            case .dateCreatedAscending:
                return indexOfImageSortedByMonth[indexOfImageSortedByMonth.count - 1 - section].count
            default:
                return 0
            }
        case .week:
            switch UploadVars.shared.localImagesSort {
            case .dateCreatedDescending:
                return indexOfImageSortedByWeek[section].count
            case .dateCreatedAscending:
                return indexOfImageSortedByWeek[indexOfImageSortedByWeek.count - 1 - section].count
            default:
                return 0
            }
        case .day:
            switch UploadVars.shared.localImagesSort {
            case .dateCreatedDescending:
                return indexOfImageSortedByDay[section].count
            case .dateCreatedAscending:
                return indexOfImageSortedByDay[indexOfImageSortedByDay.count - 1 - section].count
            default:
                return 0
            }
        case .none:
            return fetchedImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocalImageCollectionViewCell", for: indexPath) as? LocalImageCollectionViewCell else {
            debugPrint("Error: collectionView.dequeueReusableCell does not return a LocalImageCollectionViewCell!")
            return LocalImageCollectionViewCell()
        }
        
        // Get image asset and index which depends on image sort type and date order
        let index = getImageIndex(for: indexPath)
        let imageAsset = fetchedImages[index]

        // Configure cell with image asset
        cell.configure(with: imageAsset, thumbnailSize: imageCellSize)

        // Get upload state from cell data
        let uploadState = getUploadStateOfImage(at: index, for: cell)
        cell.update(selected: selectedImages[index] != nil, state: uploadState)

        // Add pan gesture recognition
        let imageSeriesRocognizer = UIPanGestureRecognizer(target: self, action: #selector(touchedImages(_:)))
        imageSeriesRocognizer.minimumNumberOfTouches = 1
        imageSeriesRocognizer.maximumNumberOfTouches = 1
        imageSeriesRocognizer.cancelsTouchesInView = false
        imageSeriesRocognizer.delegate = self
        cell.addGestureRecognizer(imageSeriesRocognizer)
        cell.isUserInteractionEnabled = true

        return cell
    }

    @objc func applyUploadProgress(_ notification: Notification) {
        if let visibleCells = localImagesCollection.visibleCells as? [LocalImageCollectionViewCell],
           let localIdentifier =  notification.userInfo?["localIdentifier"] as? String, !localIdentifier.isEmpty ,
           let cell = visibleCells.first(where: {$0.localIdentifier == localIdentifier}),
           let progressFraction = notification.userInfo?["progressFraction"] as? Float {
            cell.setProgress(progressFraction, withAnimation: true)
        }
    }
}
