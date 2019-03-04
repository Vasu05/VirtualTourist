//
//  Engine.swift
//  Virtual Tourise
//
//  Created by vasu on 20/01/19.
//  Copyright © 2019 Vasu. All rights reserved.
//

import Foundation

class Engine{
    
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url :URL ,responseType :ResponseType.Type ,body : RequestType, completion :@escaping (ResponseType? ,Error?)->Void){
        
        var request        = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody   =  try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            
            let range = Range(14..<data.count-1)
            let newData = data.subdata(in: range)
            print(String(data: data, encoding: .utf8)!)
            
            let decoder = JSONDecoder()
            
            do{
                let responseData = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                   
                    completion(responseData,nil)
                }
                
            }catch{
                
                DispatchQueue.main.async {
                    completion(nil,error)
                }
            }
        }
        task.resume()
        
    }
    
    class func taskForGETRequest<ResponseType:Decodable>(url:URL ,responseType:ResponseType.Type,completion :@escaping(ResponseType?,Error?)->Void){
        
        let task = URLSession.shared.dataTask(with: url) { (data,response, error) in
            
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
            
            
            let range = Range(14..<data.count-1)
            let newData = data.subdata(in: range)
            print(String(data: newData, encoding: .utf8)!)
            
            let decoder = JSONDecoder()
           
            do{
                let responsedata = try decoder.decode(ResponseType.self, from: newData)
                completion(responsedata,nil)
            }catch{
                completion(nil,error)
            }
            
        }
        task.resume()
    }
    
    class func seacrhPhotoUsingLatLon(lat :Double ,lon :Double, completionBlock:@escaping(PhotoSearchRootResponse?,Error?)->Void){
        
        taskForGETRequest(url: APIEndPoints.EndPoints.photoSearch(lat, lon).url, responseType: PhotoSearchRootResponse.self) { (data, error) in
            
            completionBlock(data,error)
        }
    }
    
    class func getPhotoUsing(dataObj:PhotoSearchPlaceModel,completionBlock:@escaping(Data?,Error?)->Void){
       // (let farmid,let serverid,let id,let secret)
        let url = APIEndPoints.EndPoints.getPhoto(dataObj.farm, dataObj.server, dataObj.id, dataObj.secret).url
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else{
                DispatchQueue.main.async {
                    completionBlock(nil,error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completionBlock(data,nil)
            }
            
        }
        task.resume()
        
    }
    
    
    
}
