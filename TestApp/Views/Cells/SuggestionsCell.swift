//
//  SuggestionCell.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import UIKit
import RxCocoa
import RxSwift

class SuggestionsCellViewModel {
    
    var disposeBag = DisposeBag()
    let suggestions: BehaviorRelay<[Movie]>
    let movieDidSelect = PublishSubject<IndexPath>()
    
    
    init(_ suggestions: [Movie]){
        self.suggestions = BehaviorRelay(value: suggestions)
        
        movieDidSelect.withLatestFrom(self.suggestions, resultSelector: { $1[$0.row] }).flatMap({ $0.details == nil ? RequestManager.shared.movieDetails($0) : Observable.just($0) }).subscribe(onNext: { [weak self] _movie in
            if _movie.details != nil {
                self?.navigateToDetails(_movie)
            }
        }).disposed(by: disposeBag)
    }
    
    private func navigateToDetails(_ movie: Movie){
        Navigator.shared.toDetails(movie)
    }
    
}


class SuggestionsCell: UITableViewCell {

    @IBOutlet weak var collSuggestions: UICollectionView!
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.disposeBag = DisposeBag()
        disposeBag = DisposeBag()
    }
    
    deinit {
        print("-------DEINIT---------")
        print(self)
        print("-------DEINIT---------")
    }
    
    var viewModel: SuggestionsCellViewModel!{
        didSet{ configure() }
    }
    
    
    func configure(){
        
        collSuggestions.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.suggestions.bind(to: collSuggestions.rx.items(cellIdentifier: "SuggectionCell", cellType: SuggectionCell.self)){ row, movie, cell in
            cell.viewModel = SuggectionCellViewModel(movie)
        }.disposed(by: disposeBag)
        
        collSuggestions.rx.itemSelected.bind(to: viewModel.movieDidSelect).disposed(by: disposeBag)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collSuggestions.layoutIfNeeded()
    }
    
}

extension SuggestionsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let _height = collectionView.bounds.height
        let _width = _height / 1.5
        return CGSize(width: _width, height: _height)
    }
}
