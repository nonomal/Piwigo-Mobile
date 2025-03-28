//
//  LocalImagePreviewViewController.swift
//  piwigo
//
//  Created by Eddy Lelièvre-Berna on 16/03/2024.
//  Copyright © 2024 Piwigo.org. All rights reserved.
//

import Photos
import UIKit
import piwigoKit

class LocalImagePreviewViewController: UIViewController {
    private var aspectRatio = 1.0
    private let imageView = UIImageView()
    
    init(imageAsset: PHAsset, pixelSize: CGSize) {
        super.init(nibName: nil, bundle: nil)
        
        // Retrieve image
        aspectRatio = Double(imageAsset.pixelHeight) / Double(imageAsset.pixelWidth)
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: imageAsset, targetSize: pixelSize, contentMode: .aspectFit, options: options, resultHandler: { result, info in
            DispatchQueue.main.async {
                guard let image = result else {
                    if let error = info?[PHImageErrorKey] as? Error {
                        debugPrint("••> Error : \(error.localizedDescription)")
                    }
                    self.imageView.image = pwgImageType.image.placeHolder
                    return
                }
                self.imageView.image = image
            }
        })
    }
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let width = view.bounds.width
        let height = width * aspectRatio
        preferredContentSize = CGSize(width: width, height: height)
    }
}
