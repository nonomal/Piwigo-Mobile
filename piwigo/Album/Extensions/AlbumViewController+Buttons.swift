//
//  AlbumViewController+Buttons.swift
//  piwigo
//
//  Created by Eddy Lelièvre-Berna on 12/04/2024.
//  Copyright © 2024 Piwigo.org. All rights reserved.
//

import Foundation
import UIKit
import piwigoKit
import uploadKit

extension AlbumViewController
{
    // MARK: - Buttons Management
    func initButtons() {
        // Buttons might have to be relocated:
        /// - when using several scenes on iPad
        /// - when launching the app in landscape mode on iPhone and returning to the root album in portrait mode
        if #available(iOS 13.0, *) {
            // Calculate reference position
            let xPos = view.bounds.size.width - 3 * kRadius
            let yPos = view.bounds.size.height - 3 * kRadius
            var newFrame = CGRect(x: xPos, y: yPos, width: 2 * kRadius, height: 2 * kRadius)
            
            // Relocate the "Add" button if needed
            if addButton.frame.equalTo(newFrame) == false {
                addButton.frame = newFrame
            }
            
            // Relocate the "Upload Queue" button if needed
            newFrame = getUploadQueueButtonFrame(isHidden: uploadQueueButton.isHidden)
            if uploadQueueButton.frame.equalTo(newFrame) == false {
                uploadQueueButton.frame = newFrame
            }

            // Relocate the "Home Album" button if needed
            newFrame = getHomeAlbumButtonFrame(isHidden: homeAlbumButton.isHidden)
            if homeAlbumButton.frame.equalTo(newFrame) == false {
                homeAlbumButton.frame = newFrame
            }
            
            // Relocate "Create Album" button if needed
            newFrame = getCreateAlbumButtonFrame(isHidden: createAlbumButton.isHidden)
            if createAlbumButton.frame.equalTo(newFrame) == false {
                createAlbumButton.frame = newFrame
            }
            
            // Relocate "Upload Images" button if needed
            newFrame = getUploadImagesButtonFrame(isHidden: uploadImagesButton.isHidden)
            if uploadImagesButton.frame.equalTo(newFrame) == false {
                uploadImagesButton.frame = newFrame
            }
        }
    }
    
    func updateButtons() {
        // User can upload images/videos if he/she has:
        // — admin rights
        // — normal rights and upload access to the current category
        if categoryId >= 0, user.hasUploadRights(forCatID: categoryId) {
            // Show Upload button if needed
            if addButton.isHidden {
                // Unhide transparent Add button
                addButton.isHidden = false

                // Animate appearance of Add button
                UIView.animate(withDuration: 0.3, animations: { [self] in
                    addButton.layer.opacity = 0.9
                }) { [self] finished in
                    // Fixes tintColor forgotten (often on iOS 9)
                    addButton.tintColor = UIColor.white
                    // Show button on the left of the Add button if needed
                    if ![0, AlbumVars.shared.defaultCategory].contains(categoryId) {
                        // Show Home button if not in root or default album
                        showHomeAlbumButtonIfNeeded()
                    } else {
                        // Show UploadQueue button if needed
                        let nberOfUploads = UploadVars.shared.nberOfUploadsToComplete
                        let userInfo = ["nberOfUploadsToComplete": nberOfUploads]
                        NotificationCenter.default.post(name: .pwgLeftUploads,
                                                        object: nil, userInfo: userInfo)
                    }
                }
            } else {
                // Present Home button if needed and if not in root or default album
                if ![0, AlbumVars.shared.defaultCategory].contains(categoryId) {
                    showHomeAlbumButtonIfNeeded()
                }
            }
        } else {
            // Show Home button if:
            /// - not in root or default album
            /// - not searching for images
            addButton.isHidden = true
            if ![0, AlbumVars.shared.defaultCategory, pwgSmartAlbum.search.rawValue].contains(categoryId) {
                showHomeAlbumButtonIfNeeded()
            }
        }
    }
    
    func hideButtons() {
        // Hide Upload and Home buttons
        addButton.isHidden = true
        homeAlbumButton.isHidden = true
    }

    func showOptionalButtonsCompletion(_ completion: @escaping () -> Void) {
        // Unhide transparent CreateAlbum and UploadImages buttons
        createAlbumButton.tintColor = UIColor.white
        createAlbumButton.isHidden = false
        uploadImagesButton.tintColor = UIColor.white
        uploadImagesButton.isHidden = false

        // Show CreateAlbum and UploadImages buttons
        UIView.animate(withDuration: 0.3, animations: { [self] in
            // Progressive appearance
            createAlbumButton.layer.opacity = 0.9
            uploadImagesButton.layer.opacity = 0.9

            // Move buttons together
            createAlbumButton.frame = getCreateAlbumButtonFrame(isHidden: false)
            uploadImagesButton.frame = getUploadImagesButtonFrame(isHidden: false)

            // Rotate cross and change colour
            let rotatedImage = UIImage(named: "addButton")?.rotated(by: .pi / 4)
            addButton.setImage(rotatedImage, for: .normal)
            addButton.backgroundColor = UIColor.gray
            addButton.tintColor = UIColor.white
        }) { finished in
            // Execute block
            completion()
        }
    }

    func hideOptionalButtonsCompletion(_ completion: @escaping () -> Void) {
        // Hide CreateAlbum and UploadImages buttons
        UIView.animate(withDuration: 0.3, animations: { [self] in
            // Progressive disappearance
            createAlbumButton.layer.opacity = 0.0
            uploadImagesButton.layer.opacity = 0.0

            // Move buttons towards Add button
            createAlbumButton.frame = getCreateAlbumButtonFrame(isHidden: true)
            uploadImagesButton.frame = getUploadImagesButtonFrame(isHidden: true)

            // Rotate cross if not in root and change colour
            if categoryId == 0 {
                addButton.setImage(UIImage(named: "createLarge"), for: .normal)
            } else {
                addButton.setImage(UIImage(named: "addButton"), for: .normal)
            }
            addButton.backgroundColor = UIColor.gray
            addButton.tintColor = UIColor.white
        }) { [self] finished in
            // Hide transparent CreateAlbum and UploadImages buttons
            createAlbumButton.isHidden = true
            uploadImagesButton.isHidden = true

            // Reset background colours
            createAlbumButton.backgroundColor = UIColor.piwigoColorOrange()
            uploadImagesButton.backgroundColor = UIColor.piwigoColorOrange()

            // Execute block
            completion()
        }
    }

    
    // MARK: - "Add" button above collection view and other buttons
    func getAddButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = getAddButtonFrame()
        button.layer.cornerRadius = kRadius
        button.layer.masksToBounds = false
        button.layer.opacity = 0.0
        button.layer.shadowOpacity = 0.8
        button.backgroundColor = UIColor.piwigoColorOrange()
        button.tintColor = UIColor.white
        button.showsTouchWhenHighlighted = true
        if categoryId == 0 {
            button.setImage(UIImage(named: "createLarge"), for: .normal)
        } else {
            button.setImage(UIImage(named: "addButton"), for: .normal)
        }
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        button.isHidden = true
        button.accessibilityIdentifier = "add"
        return button
    }
    
    func getAddButtonFrame() -> CGRect {
        let xPos = view.bounds.size.width - 3 * kRadius
        let yPos = view.bounds.size.height - 3 * kRadius
        return CGRect(x: xPos, y: yPos, width: 2 * kRadius, height: 2 * kRadius)
    }
    
    @objc func didTapAddButton() {
        // Create album if root album shown
        if categoryId == 0 {
            // User in root album => Create album
            addButton.backgroundColor = UIColor.gray
            addButton.tintColor = UIColor.white
            showCreateCategoryDialog()
            return
        }

        // Hide Home button behind Add button if needed
        if homeAlbumButton.isHidden {
            // Show CreateAlbum and UploadImages albums
            showOptionalButtonsCompletion({ [self] in
                // Change appearance and action of Add button
                addButton.removeTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
                addButton.addTarget( self, action: #selector(didCancelTapAddButton), for: .touchUpInside)
            })
        } else {
            // Hide Home Album button
            hideHomeAlbumButtonCompletion({ [self] in
                // Show CreateAlbum and UploadImages albums
                showOptionalButtonsCompletion({ [self] in
                    // Change appearance and action of Add button
                    addButton.removeTarget( self, action: #selector(didTapAddButton), for: .touchUpInside)
                    addButton.addTarget(self, action: #selector(didCancelTapAddButton), for: .touchUpInside)
                })
            })
        }
    }

    @objc func didCancelTapAddButton() {
        // User changed mind or finished job
        // First hide optional buttons
        hideOptionalButtonsCompletion({ [self] in
            // Reset appearance and action of Add button
            addButton.removeTarget(self, action: #selector(didCancelTapAddButton), for: .touchUpInside)
            addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
            addButton.backgroundColor = UIColor.piwigoColorOrange()
            addButton.tintColor = UIColor.white

            // Show button on the left of the Add button if needed
            if ![0, AlbumVars.shared.defaultCategory].contains(categoryId) {
                // Show Home button if not in root or default album
                showHomeAlbumButtonIfNeeded()
            }
        })
    }
    
    func showAddButtonCompletion(_ completion: @escaping () -> Void) {
        // Show Add button
        addButton.layer.opacity = 0.0
        addButton.isHidden = false

        // Show Add button
        UIView.animate(withDuration: 0.2, animations: { [self] in
            // Progressive disappearance
            addButton.layer.opacity = 1.0
        }) { finished in
            completion()
        }
    }
    
    func hideAddButtonCompletion(_ completion: @escaping () -> Void) {
        // Hide Add button
        UIView.animate(withDuration: 0.2, animations: { [self] in
            // Progressive disappearance
            addButton.layer.opacity = 0.0
        }) { [self] finished in
            addButton.isHidden = true
            completion()
        }
    }


    // MARK: - "Upload Queue" button above collection view
    func getUploadQueueButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = addButton.frame
        button.layer.cornerRadius = kRadius
        button.layer.masksToBounds = false
        button.layer.shadowOpacity = 0.8
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(didTapUploadQueueButton), for: .touchUpInside)
        button.isHidden = true
        button.backgroundColor = UIColor.clear
        return button
    }
    
    func getUploadQueueButtonFrame(isHidden: Bool) -> CGRect {
        if isHidden {
            return addButton.frame
        }
        // Resize label to fit number
        nberOfUploadsLabel.sizeToFit()

        // Adapt button width if needed
        let width = nberOfUploadsLabel.bounds.size.width + 20
        let height = nberOfUploadsLabel.bounds.size.height
        let extraWidth = CGFloat(fmax(0, Float((width - 2 * kRadius))))
        nberOfUploadsLabel.frame = CGRect(x: kRadius + (extraWidth / 2.0) - width / 2.0,
                                          y: kRadius - height / 2.0, width: width, height: height)

        progressLayer.frame = CGRect(x: 0, y: 0, width: 2 * kRadius + extraWidth, height: 2 * kRadius)
        let path = UIBezierPath(arcCenter: CGPoint(x: kRadius + extraWidth, y: kRadius), 
                                radius: kRadius - 1.5, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: kRadius, y: 2 * kRadius - 1.5))
        path.addArc(withCenter: CGPoint(x: kRadius, y: kRadius), 
                    radius: kRadius - 1.5, startAngle: .pi / 2, endAngle: .pi + .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: kRadius + extraWidth, y: 1.5))
        path.lineCapStyle = .round
        progressLayer.path = path.cgPath

        let xPos = addButton.frame.origin.x - extraWidth
        let yPos = addButton.frame.origin.y
        if addButton.isHidden {
            return CGRect(x: xPos, y: yPos,
                          width: 2 * kRadius + extraWidth, height: 2 * kRadius)
        } else {
            return CGRect(x: xPos - 3 * kRadius, y: yPos,
                          width: 2 * kRadius + extraWidth, height: 2 * kRadius)
        }
    }
    
    func getNberOfUploadsLabel() -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label
    }
    
    func getProgressLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: 2 * kRadius, height: 2 * kRadius)
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.lineJoin = .round
        layer.strokeStart = 0
        layer.strokeEnd = 0
        return layer
    }
    
    func showUploadQueueButton() {
        // Show button if needed
        if uploadQueueButton.isHidden {
            // Unhide transparent Upload Queue button
            uploadQueueButton.isHidden = false
        }

        // Animate appearance / width change of Upload Queue button
        UIView.animate(withDuration: 0.3, animations: { [self] in
            // Progressive appearance
            uploadQueueButton.layer.opacity = 0.8
            
            // Depends on number of upload requests and Add button visibility
            uploadQueueButton.frame = getUploadQueueButtonFrame(isHidden: false)
            uploadQueueButton.setNeedsLayout()
        })
    }
    
    private func hideUploadQueueButton() {
        // Hide button if not already hidden
        if uploadQueueButton.isHidden { return }
        
        // Hide Upload Queue button behind Add button
        UIView.animate(withDuration: 0.3, animations: { [self] in
            // Progressive disappearance
            uploadQueueButton.layer.opacity = 0.0

            // Animate displacement towards the Add button if needed
            uploadQueueButton.frame = getUploadQueueButtonFrame(isHidden: true)

        }) { [self] finished in
            // Hide Home Album button
            uploadQueueButton.isHidden = true
        }
    }

    @objc func updateNberOfUploads(_ notification: Notification?) {
        // Update main header if necessary
        setTableViewMainHeader()

        // Update upload queue button only in default album
        if [0, AlbumVars.shared.defaultCategory].contains(categoryId) == false {
            return
        }
        
        // Check notification data
        guard let nberOfUploads = (notification?.userInfo?["nberOfUploadsToComplete"] as? Int) else { return }

        // Only presented in the root or default album
        if nberOfUploads > 0 {
            if (!NetworkVars.shared.isConnectedToWiFi() && UploadVars.shared.wifiOnlyUploading) ||
                ProcessInfo.processInfo.isLowPowerModeEnabled {
                nberOfUploadsLabel.text = "⚠️"
            } else {
                // Set number of uploads
                let nber = String(format: "%lu", UInt(nberOfUploads))
                if nber.compare(nberOfUploadsLabel.text ?? "") == .orderedSame,
                   !uploadQueueButton.isHidden,
                   uploadQueueButton.frame != addButton.frame {
                    // Nothing ► changed  NOP
                    return
                }
                nberOfUploadsLabel.text = String(format: "%lu", UInt(nberOfUploads))
            }
            
            // Resize and show button if needed
            showUploadQueueButton()
        } else {
            // Hide button if not already hidden
            hideUploadQueueButton()
        }
    }
    
    @objc func updateUploadQueueButton(withProgress notification: Notification?) {
        guard let progress = notification?.userInfo?["progressFraction"] as? Float else { return }

        // Show button is needed
        showUploadQueueButton()
        
        // Animate progress layer of Upload Queue button
        if progress > 0.0 {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = NSNumber(value: Double(progressLayer.strokeEnd))
            animation.toValue = NSNumber(value: progress)
            progressLayer.strokeEnd = CGFloat(progress)
            progressLayer.lineCap = .round
            animation.duration = 0.2
            progressLayer.add(animation, forKey: nil)
        } else {
            // No animation
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.strokeEnd = 0.0
            CATransaction.commit()
            // Animations are disabled until here...
        }
    }


    // MARK: - "Home Album" button above collection view
    func getHomeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = addButton.frame
        button.layer.cornerRadius = kRadius
        button.layer.masksToBounds = false
        button.layer.opacity = 0.0
        button.layer.shadowOpacity = 0.8
        button.showsTouchWhenHighlighted = true
        button.setImage(UIImage(named: "rootAlbum"), for: .normal)
        button.addTarget(self, action: #selector(returnToDefaultCategory), for: .touchUpInside)
        button.isHidden = true
        return button
    }
    
    func getHomeAlbumButtonFrame(isHidden: Bool) -> CGRect {
        if isHidden {
            return addButton.frame
        }
        // Position of Home Album button depends on user's rights
        // — webmaster or admin rights
        // — normal rights and upload access to the current category
        if categoryId > 0, user.hasUploadRights(forCatID: categoryId) {
            let xPos = addButton.frame.origin.x
            let yPos = addButton.frame.origin.y
            return CGRect(x: xPos - 3 * kRadius, y: yPos,
                          width: 2 * kRadius, height: 2 * kRadius)
        } else {
            return addButton.frame
        }
    }
    
    func showHomeAlbumButtonIfNeeded() {
        // Don't present the Home button in search mode
        if categoryId == pwgSmartAlbum.search.rawValue { return }
        
        // Present Home Album button if needed
        if (homeAlbumButton.isHidden ||
            homeAlbumButton.frame.contains(addButton.frame.origin)),
           (uploadImagesButton.isHidden ||
            uploadImagesButton.frame.contains(addButton.frame.origin)),
           (createAlbumButton.isHidden ||
            createAlbumButton.frame.contains(addButton.frame.origin)) {
            // Unhide transparent Home Album button
            homeAlbumButton.isHidden = false

            // Animate appearance of Home Album button
            UIView.animate(withDuration: 0.3, animations: { [self] in
                // Progressive appearance
                homeAlbumButton.layer.opacity = 0.8

                // Position of Home Album button depends on user's rights
                homeAlbumButton.frame = getHomeAlbumButtonFrame(isHidden: false)
            })
        }
    }

    func hideHomeAlbumButtonCompletion(_ completion: @escaping () -> Void) {
        // Hide Home Album button behind Add button
        UIView.animate(withDuration: 0.2, animations: { [self] in
            // Progressive disappearance
            homeAlbumButton.layer.opacity = 0.0

            // Animate displacement towards the Add button if needed
            homeAlbumButton.frame = getHomeAlbumButtonFrame(isHidden: true)

        }) { [self] finished in
            // Hide Home Album button
            homeAlbumButton.isHidden = true

            // Execute block
            completion()
        }
    }


    // MARK: - "Create Album" button above collection view
    func getCreateAlbumButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = addButton.frame
        button.layer.cornerRadius = 0.86 * kRadius
        button.layer.masksToBounds = false
        button.layer.opacity = 0.0
        button.layer.shadowOpacity = 0.8
        button.backgroundColor = UIColor.piwigoColorOrange()
        button.tintColor = UIColor.white
        button.showsTouchWhenHighlighted = true
        button.setImage(UIImage(named: "create"), for: .normal)
        button.addTarget(self, action: #selector(addAlbum), for: .touchUpInside)
        button.isHidden = true
        button.accessibilityIdentifier = "createAlbum"
        return button
    }
    
    func getCreateAlbumButtonFrame(isHidden: Bool) -> CGRect {
        var xPos = addButton.frame.origin.x
        var yPos = addButton.frame.origin.y
        if isHidden == false {
            xPos -= 3 * kRadius * cos(15 * kDeg2Rad)
            yPos -= 3 * kRadius * sin(15 * kDeg2Rad)
        }
        return CGRect(x: xPos, y: yPos,
                      width: 1.72 * kRadius, height: 1.72 * kRadius)
    }
    
    
    // MARK: - "Upload Images" button above collection view
    func getUploadImagesButton() -> UIButton {
        let button = UIButton(type: .system)
        button.frame = addButton.frame
        button.layer.cornerRadius = 0.86 * kRadius
        button.layer.masksToBounds = false
        button.layer.opacity = 0.0
        button.layer.shadowOpacity = 0.8
        button.backgroundColor = UIColor.piwigoColorOrange()
        button.tintColor = UIColor.white
        button.showsTouchWhenHighlighted = true
        button.setImage(UIImage(named: "imageUpload"), for: .normal)
        button.addTarget(self, action: #selector(didTapUploadImagesButton), for: .touchUpInside)
        button.isHidden = true
        button.accessibilityIdentifier = "addImages"
        return button
    }

    func getUploadImagesButtonFrame(isHidden: Bool) -> CGRect {
        var xPos = addButton.frame.origin.x
        var yPos = addButton.frame.origin.y
        if isHidden == false {
            xPos -= 3 * kRadius * cos(75 * kDeg2Rad)
            yPos -= 3 * kRadius * sin(75 * kDeg2Rad)
        }
        return CGRect(x: xPos, y: yPos,
                      width: 1.72 * kRadius, height: 1.72 * kRadius)
    }

}
