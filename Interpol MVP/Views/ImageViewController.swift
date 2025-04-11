//
//  ImageViewController.swift
//  Interpol MVP
//
//  Created by Andy Kefir on 11/04/2025.
//

import UIKit

class ImageViewController: UIViewController {
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}
