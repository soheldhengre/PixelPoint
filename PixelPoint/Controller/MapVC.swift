//
//  ViewController.swift
//  PixelPoint
//
//  Created by Sohel Dhengre on 06/01/18.
//  Copyright © 2018 Sohel Dhengre. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var pullUpView: UIView!
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!
    
    var spinner:UIActivityIndicatorView?
    var screenSize = UIScreen.main.bounds
    var progressLbl: UILabel?
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    override func viewDidLoad() {
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        super.viewDidLoad()
        configureLocationServices()
        mapView.showsUserLocation = true
        centreMapOnUserLocation()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        registerForPreviewing(with: self, sourceView: collectionView!)
        pullUpView.addSubview(collectionView!)
    }

    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown(){
        cancelAllSessions()
        pullUpViewHeight.constant = 0
        UIView.animate(withDuration: 0.04) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addProgressLbl(){
         progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width/2)-120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl(){
        if progressLbl != nil{
            progressLbl?.removeFromSuperview()
        }
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width/2)-((spinner?.frame.width)!/2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
   
    @IBAction func centreLocationPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centreMapOnUserLocation()
        }
    }
    
    func animateViewUpwards(){
        pullUpViewHeight.constant = 300
        UIView.animate(withDuration: 0.04) {
            self.view.layoutIfNeeded()
        }
    }
    
    func retrieveUrls(forAnnotation annotation:DroppablePin, completion: @escaping (_ status:Bool)->()){
        
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String,AnyObject> else {return}
            do {
                let photoDict = json["photos"] as! Dictionary<String,AnyObject>
                let photoDictArray = photoDict["photo"] as! [Dictionary<String,AnyObject>]
                for photo in photoDictArray{
                    let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    self.imageUrlArray.append(postUrl)
                }

            }
            completion(true)
        }
    }
    
    func retrieveImages(completion: @escaping (_ status:Bool)->()){
        for url in imageUrlArray{
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                if self.imageArray.count == self.imageUrlArray.count{
                    completion(true)
                }
            })
        }
    }
    
    func cancelAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, DownloadData) in
            sessionDataTask.forEach({$0.cancel()})
            DownloadData.forEach({$0.cancel()})
        }
    }
}

extension MapVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    func centreMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        imageArray = []
        imageUrlArray = []
        removeAnnotation()
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        collectionView?.reloadData()
        animateViewUpwards()
        addSwipe()
        addSpinner()
        addProgressLbl()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius*2.0, regionRadius*2.0)
        mapView.setRegion(region, animated: true)
        retrieveUrls(forAnnotation: annotation) { (response) in
            if response {
                self.retrieveImages(completion: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removeAnnotation(){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}

extension MapVC: CLLocationManagerDelegate{
    func configureLocationServices(){
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centreMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        let imageAtIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageAtIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
   }

extension MapVC: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let index = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: index) else {return nil}
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else {return nil}
        popVC.initData(forImage: imageArray[index.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}


    













