//
//  MainView.swift
//  TestApp
//
//  Created by Denis Bigapps on 29/06/2022.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: - VIEWMODEL
class MainViewModel {

    let disposeBag = DisposeBag()
    // INPUT
    let searchText     = BehaviorRelay<String?>(value: nil)
    let clearDidTap    = PublishSubject<Void>()
    let movieDidSelect = PublishSubject<IndexPath>()
    
    // OUTPUT
    private let popularMovies = BehaviorRelay<[Movie]>(value: [])
    private let newMovies     = BehaviorRelay<[Movie]>(value: [])
    private let searchMovies  = BehaviorRelay<[Movie]>(value: [])
    
    var movies: Observable<[Any]> {
        return Observable.combineLatest(newMovies, searchMovies, popularMovies) { _newMovies, _searchMovies, _popularMovies in
            return _searchMovies.count > 0 ? ([_popularMovies] + _searchMovies) : ([_popularMovies] + _newMovies)
        }
    }
    
    var clearBtnHidden: Observable<Bool> {
        return searchText.map({ $0 == nil || $0!.isEmpty })
    }
    
    init(){
        
        fetchMovies()
        
        searchText.filter({ ($0?.count ?? 0) > 1 })
            .debounce(.seconds(1), scheduler: MainScheduler.asyncInstance) // limit request's times per 1 seconds
            .distinctUntilChanged()
            .flatMap({ (($0?.count ?? 0) > 1) ? RequestManager.shared.searchMovies(by: $0!) : Observable.just([]) })
            .bind(to: searchMovies).disposed(by: disposeBag)
        
        clearDidTap.map({ _ in return [] }).bind(to: searchMovies).disposed(by: disposeBag)
        clearDidTap.map({ _ in return nil }).bind(to: searchText).disposed(by: disposeBag)
        
        movieDidSelect.filter({ $0.row != 0 }).withLatestFrom(movies, resultSelector: { $1[$0.row] as! Movie }).flatMap({ $0.details == nil ? RequestManager.shared.movieDetails($0) : Observable.just($0) }).subscribe(onNext: { [weak self] _movie in
            if _movie.details != nil {
                self?.navigateToDetails(_movie)
            }
        }).disposed(by: disposeBag)
        
    }
    
    private func fetchMovies(){
        
        func fetchNewMovies(_ movies: [Movie]){
            popularMovies.accept(movies)
            RequestManager.shared.fetchHighRatedMovies().bind(to: newMovies).disposed(by: disposeBag)
        }
        
        RequestManager.shared.fetchPopularMovies().map({ Array($0.choose(5)) }).subscribe(onNext: { _movies in
            fetchNewMovies(_movies)
        }).disposed(by: disposeBag)
    }
    
    private func navigateToDetails(_ movie: Movie){
        Navigator.shared.toDetails(movie)
    }

}
    
//MARK: - VIEW
class MainView: UIViewController {
    
    
    @IBOutlet weak var tblMovies: UITableView!
    @IBOutlet weak var btnClearSearch: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    
    
    let disposeBag = DisposeBag()
    var viewModel = MainViewModel()
    var suggestionsCell: SuggestionsCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblMovies.rx.setDelegate(self).disposed(by: disposeBag)
        
        tblMovies.rx.itemSelected.bind(to: viewModel.movieDidSelect).disposed(by: disposeBag)
        
        viewModel.movies.filter({ $0.contains(where: { $0 is [Movie] }) }).bind(to: tblMovies.rx.items){ [weak self] (tbl, row, item) -> UITableViewCell in
            
            if row == 0 { // need to save cell for suggestion list for disabling reload this cell
                if self?.suggestionsCell == nil && ((item as? [Movie])?.count ?? 0) > 0 {
                    self?.suggestionsCell = tbl.dequeueReusableCell(withIdentifier: "SuggestionsCell") as? SuggestionsCell
                    self?.suggestionsCell.viewModel = SuggestionsCellViewModel(item as? [Movie] ?? [])
                }
                
                return self?.suggestionsCell ?? UITableViewCell()
            }else{
                let cell = tbl.dequeueReusableCell(withIdentifier: "MovieCell", for: IndexPath.init(row: row, section: 0)) as! MovieCell
                cell.viewModel = MovieCellViewModel(item as! Movie)
                return cell
            }

        }.disposed(by: disposeBag)
        
        viewModel.clearBtnHidden.bind(to: btnClearSearch.rx.isHidden).disposed(by: disposeBag)
        
        btnClearSearch.rx.tap.map { [weak self] _ in
            self?.txtSearch.text = nil
            return Void()
        }.bind(to: viewModel.clearDidTap).disposed(by: disposeBag)
        
        txtSearch.rx.text.bind(to: viewModel.searchText).disposed(by: disposeBag)
        
        txtSearch.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: { [weak self] _ in
            self?.view.endEditing(true)
        }).disposed(by: disposeBag)
        
    }

}

//MARK: - TABLEVIEW DELEGATE
extension MainView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 200 : UITableView.automaticDimension
    }
    
}


