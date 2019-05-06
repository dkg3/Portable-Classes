//
//  FullImageViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 5/5/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController {
    
    var currImage = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        print(currImage)
        
        let imageName = currImage
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: URL.init(string:imageName)!)
                DispatchQueue.main.async {
                    let image: UIImage = UIImage(data: data)!
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x: (self.view.frame.size.width / 2) - (image.size.width / 2), y: (self.view.frame.size.height / 2) - (image.size.height / 2), width: self.view.frame.size.width / 1.05, height: self.view.frame.size.width / 1.05)
                    imageView.center = self.view.center;
                    imageView.contentMode = .scaleAspectFit
                    self.view.addSubview(imageView)
                }
            }
            catch {
                // error
            }
        }
//        let image = UIImage(named: imageName)
//        let imageView = UIImageView(image: image!)
//        imageView.frame = CGRect(x: (self.view.frame.size.width / 2) - (image!.size.width / 2), y: (self.view.frame.size.height / 2) - (image!.size.height / 2), width: self.view.frame.size.width / 1.05, height: self.view.frame.size.width / 1.05)
//        imageView.center = self.view.center;
//        imageView.contentMode = .scaleAspectFit
//        view.addSubview(imageView)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
