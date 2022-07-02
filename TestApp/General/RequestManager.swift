//
//  RequestManager.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift
import ObjectMapper
import SDWebImage

//MARK: - CUSTOM ERROR
private enum CustomError: Error {
    case dynamic(String)
}
extension CustomError: LocalizedError {
    public var errorDescription: String? {
            switch self {
            case .dynamic(let text):
                return NSLocalizedString(text, comment: "CustomError")
            }
        }
}

//MARK: - REQUEST METHOD ENUM
private enum RequestMethod {
    
    case popular, search(String), highRated, details(Int), reviews(Int), credits(Int)
    
    var method: HTTPMethod {
        return .get
    }
    
    var url: String {
        
        let serverURL = "https://api.themoviedb.org/3"
        
        switch self {
        case .popular: return serverURL+"/discover/movie?api_key=\(MOVIE_DB_API_KEY)&sort_by=popularity.desc&language=en-US"
        case .search(let text): return serverURL+"/search/movie?api_key=\(MOVIE_DB_API_KEY)&query=\(text)"
        case .highRated: return serverURL+"/discover/movie/?api_key=\(MOVIE_DB_API_KEY)&certification_country=US&sort_by=popularity.desc"
        case .details(let id): return serverURL+"/movie/\(id)?api_key=\(MOVIE_DB_API_KEY)&language=en-US"
        case .reviews(let id): return serverURL+"/movie/\(id)/reviews?api_key=\(MOVIE_DB_API_KEY)&language=en-US&page=1"
        case .credits(let id): return serverURL+"/movie/\(id)/credits?api_key=\(MOVIE_DB_API_KEY)&language=en-US"
        }
    }
    
    
    
}

//MARK: - REQUEST MANAGER
class RequestManager {
    
    static let shared = RequestManager()
    private let manager = Alamofire.Session.default
    
    
    func movieDetails(_ movie: Movie) -> Observable<Movie> {
        
        return request(.details(movie.id)).map { _response -> Movie in
            
            if let error = _response.error {
                SHOW_TOAST(error.localizedDescription)
                return movie
            }
            
            let results = _response.rawResponseData as? [String: Any]
            let details = Mapper<Details>().map(JSON: results ?? [:])
            movie.details = details
            return movie
        }.flatMap({ [unowned self] in self._movieReviews($0) }).flatMap({ [unowned self] in self._movieCredits($0) })
        
    }
    
    private func _movieReviews(_ movie: Movie) -> Observable<Movie> {
        
        return request(.reviews(movie.id)).map { _response in
            
            if let error = _response.error {
                SHOW_TOAST(error.localizedDescription)
                return movie
            }
            
            let results = (_response.rawResponseData as? [String: Any])?["results"] as? [[String: Any]]
            let reviews = Mapper<Details.Review>().mapArray(JSONArray: results ?? [[:]])
            movie.details?.reviews = reviews
            return movie
        }
        
    }
    
    private func _movieCredits(_ movie: Movie) -> Observable<Movie> {
        
        return request(.credits(movie.id)).map { _response in
            
            if let error = _response.error {
                SHOW_TOAST(error.localizedDescription)
                return movie
            }
            
            let _cast = (_response.rawResponseData as? [String: Any])?["cast"] as? [[String: Any]]
            let _crew = (_response.rawResponseData as? [String: Any])?["crew"] as? [[String: Any]]
            let cast = Mapper<Details.Cast>().mapArray(JSONArray: _cast ?? [[:]])
            let crew = Mapper<Details.Crew>().mapArray(JSONArray: _crew ?? [[:]])
            
            movie.details?.cast = cast
            movie.details?.crew = crew
            
            return movie
        }
        
    }
    
    func searchMovies(by name: String) -> Observable<[Movie]> {

        return request(.search(name)).map { _response in
            
            if let error = _response.error {
                SHOW_TOAST(error.localizedDescription)
                return []
            }
            
            let results = (_response.rawResponseData as? [String: Any])?["results"] as? [[String: Any]]
            let movies = Mapper<Movie>().mapArray(JSONArray: results ?? [[:]])
            
            return movies
        }
        
    }
    
    func fetchHighRatedMovies() -> Observable<[Movie]> {
        
        return request(.highRated).map { _response in
            
            if let error = _response.error {
                SHOW_TOAST(error.localizedDescription)
                return []
            }
            
            let results = (_response.rawResponseData as? [String: Any])?["results"] as? [[String: Any]]
            let movies = Mapper<Movie>().mapArray(JSONArray: results ?? [[:]])
            
            return movies
        }
        
    }
    
    func fetchPopularMovies() -> Observable<[Movie]> {
        
        return request(.popular).map { _response in
            
            if let error = _response.error {
                SHOW_TOAST(error.localizedDescription)
                return []
            }
            
            let results = (_response.rawResponseData as? [String: Any])?["results"] as? [[String: Any]]
            let movies = Mapper<Movie>().mapArray(JSONArray: results ?? [[:]])
            
            return movies
        }
        
    }

    private func request(_ method: RequestMethod) -> Observable<(rawResponseData: Any?, error: Error?)> {
        
        return Observable.create { [unowned self] observer -> Disposable in
            self.manager.request(method.url, method: method.method).responseJSON { response in
                RequestManager.printRequestDebugDescription(method.url, headers: nil, params: nil, response: response)

                switch response.result {
                case .success(let data):
                    
                    if let errMessage = (data as? [String: Any])?["status_message"] as? String {
                        observer.onNext((rawResponseData:  nil, error: CustomError.dynamic(errMessage)))
                        observer.onCompleted()
                    }else{
                        observer.onNext((rawResponseData: data, error: nil))
                        observer.onCompleted()
                    }
                    
                case .failure(let err):
                    observer.onNext((rawResponseData: nil, error: err))
                    observer.onCompleted()
                }
                
            }
            
            return Disposables.create()
        }.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        
    }
//MARK: - HELPERS
    static fileprivate func printRequestDebugDescription(_ request:String?, headers: HTTPHeaders?, params:Any? , response: AFDataResponse<Any>){
        
        switch response.result{
        case .success(let data):
            print("--------------------SERVER REQUEST--------------------")
            print("Request=\(String(describing: request ?? "nil"))\n Headers=\(String(describing: headers))\n Params=\(String(describing: params ?? "nil"))\n Response=\(data)")
            print("------------------------------------------------------")

        case .failure(let error):
            print("--------------------SERVER REQUEST--------------------")
            print("Request=\(String(describing: request ?? "nil"))\n Headers=\(String(describing: headers))\n Params=\(String(describing: params ?? "nil"))\n Error=\(error)")
            print("------------------------------------------------------")
        }
    }
    
    
    static func picture(_ url: String?, isAvatar: Bool = false) -> Observable<UIImage?> {
        
        return Observable.create { observer in
            
            guard let url = url else {
                observer.onNext(ImageCache.placeholder)
                observer.onCompleted()
                return Disposables.create()
            }

            
            if let image = ImageCache.shared.imageFromCache(with: url) {
                observer.onNext(image)
                observer.onCompleted()
            }else{
                
                var urlString = ""
                
                if isAvatar {
                    if url.contains(AVATAR_URL) == true {
                        urlString = url
                    }else{
                        urlString = AVATAR_URL + url
                    }
                }else{
                    urlString = IMAGE_URL + url
                }
                
                print(urlString)
                SDWebImageDownloader.shared().downloadImage(with: URL(string: urlString), options: .continueInBackground, progress: nil) { img, _, _, _ in
                    if let img = img {
                        DispatchQueue.global(qos: .background).async {
                            ImageCache.shared.saveImageToCache(img, url: url)
                        }

                    }
                    observer.onNext(img ?? ImageCache.placeholder)
                    observer.onCompleted()
                }
                
            }
            
            return Disposables.create()
        }.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        
    }
    
}


