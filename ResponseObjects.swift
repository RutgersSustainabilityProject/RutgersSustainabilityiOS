//
//  ResponseObjects.swift
//  
//
//  Created by Vineeth Puli on 2/15/17.
//
//

import Foundation
import ObjectMapper

class TrashResponse: Mappable{
    var status : String? = "";
    var message : String? = "";
    var trash : [Trash]?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
        trash <- map["trash"]
    }
    
}

class Trash: Mappable{
    
    var userId : String? = "";
    var picture : String? = "";
    var latitude : Double?
    var longitude : Double?
    var epoch : UInt64?
    var tags : String?
    var _id : String?
    var __v : Int?
   
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map){
        userId <- map["userId"]
        picture <- map["picture"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        epoch <- map["epoch"]
        tags <- map["tags"]
        _id <- map["_id"]
        __v <- map["__v"]

    }
}
