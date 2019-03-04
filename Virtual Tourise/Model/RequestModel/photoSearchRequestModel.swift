//
//  photoSearchRequestModel.swift
//  Virtual Tourise
//
//  Created by vasu on 21/01/19.
//  Copyright © 2019 Vasu. All rights reserved.
//

import Foundation

struct photoSearchRequestModel: Codable{
    
   // let method    : String
    let key       : String
    let latitude  : Double
    let longitude : Double
    let format    : String
    
    enum CodingKeys: String, CodingKey{
        
        //case method
        case key = "api_key"
        case latitude = "lat"
        case longitude = "lon"
        case format 
    }
}
