///Users/denisbigapps/Documents/BiGapps/TestApp/TestApp/Views/DetailsView.swift
//  DetailsView.swift
//  TestApp
//
//  Created by Denis Bigapps on 01/07/2022.
//

import UIKit
import RxCocoa
import RxSwift


//MARK: - VIEWMODEL
class DetailsViewModel {
    
    let disposeBag = DisposeBag()
    private var _movie: BehaviorRelay<Movie>
    // OUTPUT
    var poster: Observable<UIImage?> {
        return _movie.flatMap({ RequestManager.picture($0.posterPath) }).map({ $0?.resizeImage(newSize: CGSize(width: 127, height: 190)) })
    }
    var rating: Observable<String?> {
        return _movie.map({ $0.voteAverage?.toString })
    }
    var title: Observable<String?> {
        return _movie.map({ $0.title })
    }
    var popularity: Observable<String?> {
        return _movie.map({ $0.details?.popularity != nil ? "Popularity: \(Int($0.details!.popularity!))" : nil })
    }
    var budget: Observable<String?> {
        return _movie.map({ $0.details?.budget != nil ? "Budget: \($0.details!.budget!)" : nil })
    }
    var genres: Observable<String?> {
        return _movie.map({ $0.details?.genres != nil ? "Genres: \($0.details!.genres!)" : nil })
    }
    var isHomePageHidden: Observable<Bool> {
        return _movie.map({ $0.details?.homepage == nil })
    }
    var cast: Observable<[Details.Cast]> {
        return _movie.map({ $0.details?.cast ?? [] })
    }
    var crew: Observable<[Details.Crew]> {
        return _movie.map({ $0.details?.crew ?? [] })
    }
    var reviews: Observable<[Details.Review]> {
        return _movie.map({ $0.details?.reviews.sorted(by: { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }) ?? [] })
    }
    
    // INPUT
    let homePageDidTap = PublishSubject<Void>()
    
    init(_ movie: Movie){
        _movie = BehaviorRelay(value: movie)
        
        homePageDidTap.withLatestFrom(_movie.map({ $0.details?.homepage })).subscribe(onNext: { _homePage in
            
            guard let url = URL(string: _homePage ?? ""),
                  UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }).disposed(by: disposeBag)
    }
    
    func getMovieForShare() -> Observable<Movie> {
        return _movie.asObservable()
    }
    
}

//MARK: - VIEW
class DetailsView: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton! {
        didSet{ btnBack.rx.tap.subscribe(onNext: { _ in
            Navigator.shared.back()
        }).disposed(by: disposeBag) }
    }
    
    // top view
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPolularity: UILabel!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblGenres: UILabel!
    @IBOutlet weak var btnHomePage: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    // bottom view
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewForScroll: UIView!
    var addInfo: [AddInfo] = []
    
    let disposeBag = DisposeBag()
    var viewModel: DetailsViewModel!
    
    var gestureRecognizer: UIGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.poster.bind(to: ivPoster.rx.image).disposed(by: disposeBag)
        viewModel.rating.bind(to: lblRating.rx.text).disposed(by: disposeBag)
        viewModel.title.bind(to: lblTitle.rx.text).disposed(by: disposeBag)
        viewModel.popularity.bind(to: lblPolularity.rx.text).disposed(by: disposeBag)
        viewModel.budget.bind(to: lblBudget.rx.text).disposed(by: disposeBag)
        viewModel.genres.bind(to: lblGenres.rx.text).disposed(by: disposeBag)
        viewModel.isHomePageHidden.bind(to: btnHomePage.rx.isHidden).disposed(by: disposeBag)
        
        btnHomePage.rx.tap.bind(to: viewModel.homePageDidTap).disposed(by: disposeBag)
        btnShare.rx.tap.withLatestFrom(viewModel.getMovieForShare()).subscribe(onNext: { [weak self] _movie in
            self?.shareMovie(_movie)
        }).disposed(by: disposeBag)
        
    }
    
    var didConfigureTabs = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !didConfigureTabs {
            configureTabsViews()
            didConfigureTabs = true
        }

    }
    
    private func configureTabsViews(){
        let _frame = viewForScroll.frame
        let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: _frame.width, height: _frame.height))
        
        scroll.showsHorizontalScrollIndicator = false
        scroll.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        scroll.isPagingEnabled = true
        
        for i in 0..<3 {
            let x = _frame.width * CGFloat(i)
            let _f = CGRect(x: x, y: 0, width: _frame.width, height: _frame.height)
            let _addInfo = AddInfo(frame: _f)
            self.addInfo.append(_addInfo)
            scroll.addSubview(_addInfo)
        }
            
        scroll.contentSize = CGSize(width: 3*_frame.width, height: _frame.height)
        viewForScroll.addSubview(scroll)
        configureDataTabs()
        
        scroll.rx.currentPage.bind(to: pageControl.rx.currentPage).disposed(by: disposeBag)
        pageControl.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] _ in
            guard let currentPage = self?.pageControl.currentPage else { return }
            scroll.setCurrentPage(currentPage, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func configureDataTabs(){
        
        guard addInfo.count == 3 else { return }
        
        addInfo[0].tblContent.register(UINib(nibName: "AddInfoStaffCell", bundle: nil), forCellReuseIdentifier: "AddInfoStaffCell")
        addInfo[1].tblContent.register(UINib(nibName: "AddInfoStaffCell", bundle: nil), forCellReuseIdentifier: "AddInfoStaffCell")
        addInfo[2].tblContent.register(UINib(nibName: "AddInfoReviewCell", bundle: nil), forCellReuseIdentifier: "AddInfoReviewCell")
        
        addInfo[0].lblType.text = "Cast"
        addInfo[1].lblType.text = "Crew"
        addInfo[2].lblType.text = "Reviews"
        
        addInfo[0].tblContent.rx.setDelegate(self).disposed(by: disposeBag)
        addInfo[1].tblContent.rx.setDelegate(self).disposed(by: disposeBag)
        addInfo[2].tblContent.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.cast.bind(to: addInfo[0].tblContent.rx.items(cellIdentifier: "AddInfoStaffCell", cellType: AddInfoStaffCell.self)){ row, cast, cell in
            cell.viewModel = AddInfoStaffCellViewModel(cast)
        }.disposed(by: disposeBag)

        viewModel.crew.bind(to: addInfo[1].tblContent.rx.items(cellIdentifier: "AddInfoStaffCell", cellType: AddInfoStaffCell.self)){ row, crew, cell in
            cell.viewModel = AddInfoStaffCellViewModel(crew)
        }.disposed(by: disposeBag)
        
        viewModel.reviews.bind(to: addInfo[2].tblContent.rx.items(cellIdentifier: "AddInfoReviewCell", cellType: AddInfoReviewCell.self)){ row, review, cell in
            cell.viewModel = AddInfoReviewCellViewModel(review)
        }.disposed(by: disposeBag)
        
        addInfo[0].tblContent.reloadData()
        
    }
    
    

}

//MARK: - TABLEVIEW DELEGATE
extension DetailsView: UIGestureRecognizerDelegate, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // for 'reviews' we give dynamic height
        if tableView == addInfo[2].tblContent { return UITableView.automaticDimension }
        return 120
    }
    
    // when you need the both scroll type horizontal and also vertical.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.gestureRecognizer == gestureRecognizer {
            if let scroll = otherGestureRecognizer.view as? UIScrollView {
                if scroll.contentOffset.x == 0 {
                    return true
                }
            }
        }
        return false
    }
    
}

//MARK: - SHARE MOVIE
extension DetailsView {
    
    fileprivate func shareMovie(_ movie: Movie){
        
        var items: [Any] = []
        // Setting description
        if let firstActivityItem = movie.title {
            items.append(firstActivityItem)
        }
        
        // Setting url
        if let secondActivityItem: String = movie.details?.homepage, let url = URL(string: secondActivityItem) {
            items.append(url)
        }
        
        // If you want to use an image
        if let image: UIImage = ivPoster.image {
            items.append(image)
        }
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: items, applicationActivities: nil)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        if #available(iOS 13.0, *) {
            activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
        }
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        if #available(iOS 13.0, *) {
            activityViewController.isModalInPresentation = true
        }
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
}

