//
//  ImageViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 16/03/2025.
//

import UIKit

class ImageViewController: UIViewController {
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
 
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        view.addSubview(blurEffectView)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
