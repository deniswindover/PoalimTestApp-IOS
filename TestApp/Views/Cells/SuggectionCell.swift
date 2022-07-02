//
//  SuggectionCell.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import UIKit
import RxCocoa
import RxSwift


class SuggectionCellViewModel {
    
    var disposeBag = DisposeBag()
    private var _movie: BehaviorRelay<Movie>
    var poster: Observable<UIImage?> {
        return _movie.flatMap({ RequestManager.picture($0.posterPath) }).map({ $0?.resizeImage(newSize: CGSize(width: 127, height: 190)) })
    }
    var rating: Observable<String?> {
        return _movie.map({ $0.voteAverage?.toString })
    }
    
    init(_ movie: Movie){
        _movie = BehaviorRelay(value: movie)
    }
    
}


class SuggectionCell: UICollectionViewCell {
    
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var lblRating: UILabel!
    
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.disposeBag = DisposeBag()
        disposeBag = DisposeBag()
        ivPoster.image = nil
    }
    
    deinit {
        print("-------DEINIT---------")
        print(self)
        print("-------DEINIT---------")
    }
    
    var viewModel: SuggectionCellViewModel! {
        didSet { self.configure() }
    }
    
    func configure(){
        
        viewModel.poster.map({ $0 == nil }).bind(to: loader.rx.isAnimating).disposed(by: disposeBag)
        
        viewModel.poster.bind(to: ivPoster.rx.image).disposed(by: disposeBag)
        
        viewModel.rating.bind(to: lblRating.rx.text).disposed(by: disposeBag)
    }
    
}

extension Float{
    
    public var toString: String{
        return "\(self)"
    }
    
}
