
//
//  Networking.swift
//  Hawk
//
//  Created by Shreyas Hirday on 11/12/16.
//  Copyright © 2016 HirDaysOfTheWeek. All rights reserved.
//
import Foundation
import Alamofire
import AlamofireObjectMapper


class Networking {
    
    var url: String? {
        return "https://powerful-ocean-97485.herokuapp.com"
    }
    
    class func postTrash(userId : String, picture : String, latitude : Double, longitude :  Double, epoch : UInt64, tags : String, completionHandler : @escaping (TrashResponse?, NSError?) -> ()) {
        let postTrashURL = Networking().url! + "/trash/postTrash"
        Alamofire.upload(multipartFormData: {multipartFormData in
            multipartFormData.append(userId.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "userId")
            multipartFormData.append(picture.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "trashPhoto")
            multipartFormData.append(String(latitude).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "latitude")
            multipartFormData.append(String(longitude).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "longitude")
            multipartFormData.append(String(epoch).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "epoch")
            multipartFormData.append(tags.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName : "tags")
            
        }
            , to: postTrashURL, encodingCompletion:
            { encodingResult in
                switch encodingResult {
                case.success(let upload, _, _):
                    upload.responseObject {
                        (response: DataResponse<TrashResponse>) in
                        switch response.result {
                        case .success(let value):
                            completionHandler(value as TrashResponse, nil)
                        case .failure(let error):
                            completionHandler(nil, error as NSError?)
                        }
                    }
                case .failure(let encodingError):
                    completionHandler(nil, encodingError as NSError?)
                }
        })
    }
//class func getTrash(userId: String, completionHandler:@escaping (AuthenticationResponse?, NSError?) -> ()) authenticationresponse gives error
  class func getTrash(userId: String, completionHandler:@escaping (TrashResponse?, NSError?) -> ()) {
        let getTrashUrl = Networking().url! + "/trash/getTrashByUserId"
    let parameters: Parameters = ["userId" : userId]
    Alamofire.request(getTrashUrl, parameters : parameters).responseObject { ( response: DataResponse<TrashResponse>) in
            switch response.result {
            case .success(let value):
                completionHandler(value as TrashResponse, nil)
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }

 
    
    
}
