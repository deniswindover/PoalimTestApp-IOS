//
//  MovieCell.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import UIKit
import RxCocoa
import RxSwift
import DWExt

class MovieCellViewModel {
    
    var disposeBag = DisposeBag()
    private var _movie: BehaviorRelay<Movie>
    var poster: Observable<UIImage?> {
        return _movie.flatMap({ RequestManager.picture($0.posterPath) }).map({ $0?.resizeImage(newSize: CGSize(width: 95, height: 142)) }).observe(on: MainScheduler.asyncInstance)
    }
    var rating: Observable<String?> {
        return _movie.map({ $0.voteAverage?.toString })
    }
    var title: Observable<String?> {
        return _movie.map({ $0.title })
    }
    var releaseDate: Observable<String?> {
        return _movie.map({ "Release Date: " + ($0.releaseDate?.fullDateDotSep ?? "") })
    }
    var overview: Observable<String?> {
        return _movie.map({ $0.overview })
    }
    var votes: Observable<String?> {
        return _movie.map({ $0.voteCount != nil ? "Votes: \($0.voteCount!.toString)" : nil })
    }
    
    init(_ movie: Movie){
        _movie = BehaviorRelay(value: movie)
    }
    
}


class MovieCell: UITableViewCell {

    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblReleaseDate: UILabel!
    @IBOutlet weak var txtOverview: UITextView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblVotes: UILabel!
    
    
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivPoster.image = nil
        viewModel.disposeBag = DisposeBag()
        disposeBag = DisposeBag()
    }
    
    deinit {
        print("-------DEINIT---------")
        print(self)
        print("-------DEINIT---------")
    }
    
    var viewModel: MovieCellViewModel!{
        didSet{ configure() }
    }
    
    
    func configure(){
        
        viewModel.poster.map({ $0 == nil }).bind(to: loader.rx.isAnimating).disposed(by: disposeBag)
        viewModel.poster.bind(to: ivPoster.rx.image).disposed(by: disposeBag)
        viewModel.title.bind(to: lblTitle.rx.text).disposed(by: disposeBag)
        viewModel.releaseDate.bind(to: lblReleaseDate.rx.text).disposed(by: disposeBag)
        viewModel.overview.bind(to: txtOverview.rx.text).disposed(by: disposeBag)
        viewModel.rating.bind(to: lblRating.rx.text).disposed(by: disposeBag)
        viewModel.votes.bind(to: lblVotes.rx.text).disposed(by: disposeBag)
        
    }
    
}
