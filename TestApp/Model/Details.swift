//
//  Details.swift
//  TestApp
//
//  Created by Denis Bigapps on 01/07/2022.
//

import Foundation
import ObjectMapper


class Details: Mappable {
    
    var popularity: Double?
    private var _budget: Int?
    private var _genres: [Genre]?
    var homepage: String?
    var reviews: [Review] = []
    var cast: [Cast] = []
    var crew: [Crew] = []
    
    required init?(map: Map) {

    }
    
    var budget: String? {
        guard let _budget = _budget else { return nil }
        let millions = _budget / 1000000
        
        if millions > 0 {
            return millions.toString+"M"
        }else{
            return "<1M"
        }
    }
    
    var genres: String? {
        guard let _genres = _genres,
              _genres.count > 0 else { return nil }

        return _genres.map({ $0.name }).joined(separator: ", ")
        
    }
    
    func mapping(map: Map) {
        popularity <- map["popularity"]
        _budget <- map["budget"]
        _genres <- map["genres"]
        homepage <- map["homepage"]
    }
    
    class Cast: Staff {

        var character: String?

        required init?(map: Map) {
            super.init(map: map)
            character <- map["character"]
        }

        override func mapping(map: Map) {
        }

    }

    class Crew: Staff {

        var job: String?

        required init?(map: Map) {
            super.init(map: map)
            job <- map["job"]
        }

        override func mapping(map: Map) {
        }

    }
    
    class Staff: Mappable {
        
        
        var id: Int
        var name: String?
        var popularity: Double?
        var profile: String?
        
        required init?(map: Map) {
            guard let _id: Int = map["id"].value() else{ return nil }
            id = _id
            
            name <- map["name"]
            popularity <- map["popularity"]
            profile <- map["profile_path"]
        }
        
        func mapping(map: Map) {
        }
        
    }
    

    
    struct Review: Mappable {
        
        var author: String
        var avatar: String?
        var rating: Int?
        var createdAt: Date?
        var content: String?
        
        init?(map: Map) {
            guard let _author: String = map["author"].value() else{ return nil }
            author = _author
        }
        
        mutating func mapping(map: Map) {
            avatar <- map["author_details.avatar_path"]
            if avatar?.first == "/" { avatar = String(avatar!.dropFirst()) }
            rating <- map["author_details.rating"]
            content <- map["content"]
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

            if let _createdAt = map["created_at"].currentValue as? String, let _date = dateFormatter.date(from: _createdAt) {
                createdAt = _date
            }
        }
        
    }
    
    struct Genre: Mappable {
        
        var name: String
        
        init?(map: Map) {
            guard let _name: String = map["name"].value() else{ return nil }
            name = _name
        }
        
        func mapping(map: Map) {
        }
        
    }
    
}
