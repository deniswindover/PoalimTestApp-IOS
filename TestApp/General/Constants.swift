//
//  Constants.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import Foundation
import DWExt

let MOVIE_DB_API_KEY = "ab0a6e8ac83f35e76677927702179b94"

let IMAGE_URL = "https://image.tmdb.org/t/p/original"
let AVATAR_URL = "https://www.gravatar.com/avatar/"

func SHOW_TOAST(_ text:String){
    DTIToastCenter.defaultCenter.makeText(text: text)
}
