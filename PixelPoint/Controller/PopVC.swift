//
//  PopVC.swift
//  PixelPoint
//
//  Created by Sohel Dhengre on 10/01/18.
//  Copyright © 2018 Sohel Dhengre. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    var image: UIImage!
    
    func initData(forImage image:UIImage){
        self.image = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = image
        addDoubleTap()
    }

    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func doubleTapped(){
    self.dismiss(animated: true, completion: nil)
    }

}
