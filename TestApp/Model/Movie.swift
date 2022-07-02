//
//  Movie.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import Foundation
import ObjectMapper



class Movie: Mappable {
    
    var id: Int
    var overview: String?
    var posterPath: String?
    var releaseDate: Date?
    var title: String?
    var voteAverage: Float?
    var voteCount: Int?
    
    var details: Details?
    
    required init?(map: Map) {
        guard let _id: Int = map["id"].value() else{ return nil }
        id = _id
    }
    
    func mapping(map: Map) {
        overview <- map["overview"]
        posterPath <- map["poster_path"]
        title <- map["title"]
        voteAverage <- map["vote_average"]
        voteCount <- map["vote_count"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let _releaseDate = map["release_date"].currentValue as? String, let _date = dateFormatter.date(from: _releaseDate) {
            releaseDate = _date
        }
        
    }
    
}
