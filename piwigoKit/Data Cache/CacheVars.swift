//
//  CacheVars.swift
//  piwigoKit
//
//  Created by Eddy Lelièvre-Berna on 06/06/2021.
//  Copyright © 2021 Piwigo.org. All rights reserved.
//

import Foundation

public class CacheVars: NSObject {
    
    // Singleton
    public static let shared = CacheVars()
    
    // Remove deprecated stored objects if needed
    //    override init() {
    //        // Deprecated data?
    //        if let _ = UserDefaults.standard.object(forKey: "test") {
    //            UserDefaults.standard.removeObject(forKey: "test")
    //        }
    //        if let _ = UserDefaults.dataSuite.object(forKey: "test") {
    //            UserDefaults.dataSuite.removeObject(forKey: "test")
    //        }
    //    }
    
    // MARK: - Vars in UserDefaults / Standard
    // Data cache variables stored in UserDefaults / Standard
    /// - Core Data migration issue
    @UserDefault("couldNotMigrateCoreDataStore", defaultValue: false)
    public var couldNotMigrateCoreDataStore: Bool
    
    /// - Recent period in number of days
    public let recentPeriodKey = 594 // i.e. key used to detect the behaviour of the slider (sum of all periods)
    public let recentPeriodList:[Int] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,30,40,50,60,80,99]
    @UserDefault("recentPeriodIndex", defaultValue: 7)      // i.e index of the period of 7 days
    public var recentPeriodIndex: Int
    
    public let recentPeriodListChangedInVersion312 = "3.1.2"
    @UserDefault("recentPeriodIndexCorrectedInVersion321", defaultValue: false)
    public var recentPeriodIndexCorrectedInVersion321: Bool
    
    
    // MARK: - Vars in UserDefaults / App Group
    // Variables stored in UserDefaults / App Group
    /// - none
    
    
    // MARK: - Vars in Memory
    // Variables kept in memory
    public let optImage = "-opt"    
}
