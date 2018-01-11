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
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var ownerLbl: UILabel!
    var image: UIImage!
    var photoTitle:String!
    var photoOwner:String!
    
    func initData(forImage image:UIImage, fortitle title:String, and owner:String){
        self.image = image
        self.photoTitle = title
        self.photoOwner = owner
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = image
        titleLbl.text = photoTitle
        ownerLbl.text = photoOwner
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
