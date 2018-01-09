//
//  Constants.swift
//  PixelPoint
//
//  Created by Sohel Dhengre on 09/01/18.
//  Copyright © 2018 Sohel Dengre. All rights reserved.
//

import Foundation

let apiKey = "7d77c7bfe04c775aaea2b4ff1608a9bf"

func flickrUrl(forApiKey key:String, withAnnotation annotation:DroppablePin, andNumberOfPhotos number:Int) -> String{
     return " https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}
