//
//  PwgSession+Images.swift
//  piwigoKit
//
//  Created by Eddy Lelièvre-Berna on 27/06/2023.
//  Copyright © 2023 Piwigo.org. All rights reserved.
//

import os
import Foundation

public extension PwgSession {
    
    func getIDofImage(withMD5 md5sum: String,
                      completion: @escaping (Int64?) -> Void,
                      failure: @escaping (Error?) -> Void) {
        // Launch request
        let paramDict: [String : Any] = ["md5sum_list": md5sum]
        postRequest(withMethod: pwgImagesExist, paramDict: paramDict,
                    jsonObjectClientExpectsToReceive: ImagesExistJSON.self,
                    countOfBytesClientExpectsToReceive: pwgImagesExistBytes) { jsonData in
            do {
                // Decode the JSON into codable type ImagesExistJSON.
                let decoder = JSONDecoder()
                let pwgData = try decoder.decode(ImagesExistJSON.self, from: jsonData)

                // Piwigo error?
                if pwgData.errorCode != 0 {
                    // Will retry later
                    let error = PwgSession.shared.error(for: pwgData.errorCode, errorMessage: pwgData.errorMessage)
                    failure(error)
                    return
                }

                if let imageID = pwgData.data.first(where: {$0.md5sum == md5sum})?.imageID {
                    completion(imageID)
                } else {
                    completion(nil)
                }
            }
            catch {
                failure(error)
                return
            }
        } failure: { error in
            /// - Network communication errors
            /// - Returned JSON data is empty
            /// - Cannot decode data returned by Piwigo server
            failure(error)
        }
    }

    func setInfos(with paramsDict: [String: Any],
                  completion: @escaping () -> Void,
                  failure: @escaping (Error) -> Void) {
        postRequest(withMethod: pwgImagesSetInfo, paramDict: paramsDict,
                    jsonObjectClientExpectsToReceive: ImagesSetInfoJSON.self,
                    countOfBytesClientExpectsToReceive: pwgImagesSetInfoBytes) { jsonData in
            // Decode the JSON object and check if image data were updated on server.
            do {
                // Decode the JSON into codable type ImagesSetInfoJSON.
                let decoder = JSONDecoder()
                let pwgData = try decoder.decode(ImagesSetInfoJSON.self, from: jsonData)
                
                // Piwigo error?
                if pwgData.errorCode != 0 {
                    let error = PwgSession.shared.error(for: pwgData.errorCode, errorMessage: pwgData.errorMessage)
                    failure(error)
                    return
                }
                
                // Successful?
                if pwgData.success {
                    // Image properties successfully updated ▶ update image
                    completion()
                }
                else {
                    // Could not set image parameters
                    failure(PwgSessionError.unexpectedError)
                }
            } catch {
                // Data cannot be digested
                failure(error)
            }
        } failure: { error in
            /// - Network communication errors
            /// - Returned JSON data is empty
            /// - Cannot decode data returned by Piwigo server
            failure(error)
        }
    }
}
