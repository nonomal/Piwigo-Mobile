//
//  AlbumVars.shared.swift
//  piwigo
//
//  Created by Eddy Lelièvre-Berna on 25/05/2021.
//  Copyright © 2021 Piwigo.org. All rights reserved.
//

import Foundation
import UIKit
import piwigoKit

class AlbumVars: NSObject {
        
    // Singleton
    static let shared = AlbumVars()
    
    // Remove deprecated stored objects if needed
    override init() {
        // Deprecated data?
        if let _ = UserDefaults.standard.object(forKey: "recentPeriod") {
            UserDefaults.standard.removeObject(forKey: "recentPeriod")
        }
        if let defaultSort = UserDefaults.standard.object(forKey: "defaultSort") {
            UserDefaults.standard.removeObject(forKey: "defaultSort")
            if UserDefaults.standard.object(forKey: "defaultSortRaw") == nil {
                UserDefaults.standard.set(defaultSort, forKey: "defaultSortRaw")
            }
        }
//        if let _ = UserDefaults.dataSuite.object(forKey: "test") {
//            UserDefaults.dataSuite.removeObject(forKey: "test")
//        }
    }

    // MARK: - Vars in UserDefaults / Standard
    // Album variables stored in UserDefaults / Standard
    /// - Default root album, 0 by default
    @UserDefault("defaultCategory", defaultValue: Int32.zero)
    var defaultCategory: Int32

    /// - Default album thumbnail size determined from the available image sizes to present 144x144 pixel thumbnails
    @UserDefault("defaultAlbumThumbnailSize", defaultValue: AlbumUtilities.optimumAlbumThumbnailSizeForDevice().rawValue)
    var defaultAlbumThumbnailSize: Int16

    /// - List of albums recently visited / used
    @UserDefault("recentCategories", defaultValue: "0")
    var recentCategories: String
    
    /// - Maximum number of recent abums  presented to the user
    @UserDefault("maxNberRecentCategories", defaultValue: 5)
    var maxNberRecentCategories: Int
    
    /// - Display album description in collection views
    @UserDefault("displayAlbumDescriptions", defaultValue: false)
    var displayAlbumDescriptions: Bool

    /// - Default image sort option
    @UserDefault("defaultSortRaw", defaultValue: pwgImageSort.albumDefault.rawValue)
    private var defaultSortRaw: Int16
    var defaultSort: pwgImageSort {
        get { return pwgImageSort(rawValue: defaultSortRaw) ?? .albumDefault }
        set(value) {
            if pwgImageSort.allCases.contains(value) {
                defaultSortRaw = value.rawValue
            }
        }
    }

    /// - Default grouping option when sorting images by date
    @UserDefault("defaultGroupRaw", defaultValue: pwgImageGroup.none.rawValue)
    private var defaultGroupRaw: Int16
    var defaultGroup: pwgImageGroup {
        get { return pwgImageGroup(rawValue: defaultGroupRaw) ?? .none }
        set(value) {
            if pwgImageGroup.allCases.contains(value) {
                defaultGroupRaw = value.rawValue
            }
        }
    }

    /// - Display images titles in collection views
    @UserDefault("displayImageTitles", defaultValue: true)
    var displayImageTitles: Bool

    /// - Image thumbnail size determined from the available image sizes
    @UserDefault("defaultThumbnailSize", defaultValue: AlbumUtilities.optimumThumbnailSizeForDevice().rawValue)
    var defaultThumbnailSize: Int16

    /// - Number of images per row in portrait mode
    @UserDefault("thumbnailsPerRowInPortrait", defaultValue: UIDevice.current.userInterfaceIdiom == .phone ? 4 : 6)
    var thumbnailsPerRowInPortrait: Int
    

    // MARK: - Vars in UserDefaults / App Group
    // Album variables stored in UserDefaults / App Group
    /// - None


    // MARK: - Vars in Memory
    // Album variables kept in memory
    /// - To remember which album data is being fetched
    var isFetchingAlbumData = Set<Int32>()
}
