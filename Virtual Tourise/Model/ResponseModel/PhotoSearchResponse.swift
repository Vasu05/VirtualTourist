//
//  PhotoSearchResponse.swift
//  Virtual Tourise
//
//  Created by vasu on 21/01/19.
//  Copyright © 2019 Vasu. All rights reserved.
//

//{
//    "places": {
//        "place": [
//        {
//        "place_id": "QCgnOGhTW7iMEnmVsg",
//        "woeid": "29215543",
//        "latitude": 28.703,
//        "longitude": 77.109,
//        "place_url": "\/India\/Delhi\/Delhi\/Rohini+Sector+3",
//        "place_type": "neighbourhood",
//        "place_type_id": 22,
//        "timezone": "Asia\/Kolkata",
//        "name": "Rohini Sector 3, Delhi, DL, IN, India",
//        "woe_name": "Rohini Sector 3"
//        }
//        ],
//        "latitude": 28.7041,
//        "longitude": 77.1025,
//        "accuracy": 16,
//        "total": 1
//    },
//    "stat": "ok"
//}

import Foundation

struct PhotoSearchRootResponse:Codable{
    let photos : PhotoSearchPlaceResponse
    let stat   : String
}

struct PhotoSearchPlaceResponse :Codable{
    let photo         : [PhotoSearchPlaceModel]
    let page          :Int
    let pages         :Int
    let perpage       :Int
    let total         :String
}

struct PhotoSearchPlaceModel :Codable{
    let id            :String
    let owner         :String
    let secret        :String
    let server        :String
    let title         :String
    let farm          :Int
    let ispublic      :Int
    let isfriend      :Int
    let isfamily      :Int
}
