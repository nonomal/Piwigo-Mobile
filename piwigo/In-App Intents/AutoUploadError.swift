//
//  AutoUploadError.swift
//  piwigo
//
//  Created by Eddy Lelièvre-Berna on 15/06/2025.
//  Copyright © 2025 Piwigo.org. All rights reserved.
//

import Foundation

public enum AutoUploadError: Error {
    case migrationRequired
    case autoUploadDisabled
    case invalidSource
    case invalidDestination
    case importFailed
}

extension AutoUploadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .migrationRequired:
            return NSLocalizedString("CoreData_MigrationRequired",
                                     comment: "The persistent database of your Piwigo data requires migration. Please launch the application.")
        case .autoUploadDisabled:
            return NSLocalizedString("AutoUploadError_Disabled",
                                     comment: "Auto-uploading is disabled in the app settings.")
        case .invalidSource:
            return NSLocalizedString("settings_autoUploadSourceInvalid", comment:"Invalid source album") + ": " +
                    NSLocalizedString("settings_autoUploadSourceInfo", comment: "Please select the album…")
        case .invalidDestination:
            return NSLocalizedString("settings_autoUploadDestinationInvalid", comment:"Invalid destination album") + ": " +
                    NSLocalizedString("settings_autoUploadSourceInfo", comment: "Please select the album…")
        case .importFailed:
            return "Could not create upload requests."
        }
    }
}
