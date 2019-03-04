//
//  APIEndPoints.swift
//  Virtual Tourise
//
//  Created by vasu on 20/01/19.
//  Copyright © 2019 Vasu. All rights reserved.
//

import Foundation

class APIEndPoints{
    
    enum EndPoints {
        
        static let base = "https://www.flickr.com/services/api/explore/flickr.photos.search"
        
        case photoSearch(Double,Double)

        case getPhoto(Int,String,String,String)
      
        var stringValue: String {
            switch self {
            case .photoSearch(let lat,let lon):
                return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(AppCredentials.REST_API_Key)&lat=\(lat)&lon=\(lon)&format=json"
            case .getPhoto(let farmid,let serverid,let id,let secret):
                return    "https://farm\(farmid).staticflickr.com/\(serverid)/\(id)_\(secret).jpg"
  
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
}
