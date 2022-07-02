//
//  AddInfoReviewCell.swift
//  TestApp
//
//  Created by Denis Bigapps on 01/07/2022.
//

import UIKit
import RxCocoa
import RxSwift
import DWExt


class AddInfoReviewCellViewModel {
    
    var disposeBag = DisposeBag()
    private var _review: BehaviorRelay<Details.Review>
    var avatar: Observable<UIImage?> {
        return _review.flatMap({ RequestManager.picture($0.avatar, isAvatar: true) }).map({ $0?.cropImageToSquare() }).observe(on: MainScheduler.asyncInstance)
    }
    var author: Observable<String?> {
        return _review.map({ $0.author })
    }
    var rating: Observable<String?> {
        return _review.map({ "Rating: \($0.rating?.toString ?? "")" })
    }
    var date: Observable<String?> {
        return _review.map({ $0.createdAt?.fullDateDotSep })
    }
    var content: Observable<String?> {
        return _review.map({ $0.content })
    }
    
    init(_ review: Details.Review){
        _review = BehaviorRelay(value: review)
    }
    
}

class AddInfoReviewCell: UITableViewCell {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var txtContent: UITextView!
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivAvatar.image = nil
        viewModel.disposeBag = DisposeBag()
        disposeBag = DisposeBag()
    }
    
    deinit {
        print("-------DEINIT---------")
        print(self)
        print("-------DEINIT---------")
    }
    
    var viewModel: AddInfoReviewCellViewModel!{
        didSet{ configure() }
    }
    
    
    func configure(){
        
        viewModel.avatar.bind(to: ivAvatar.rx.image).disposed(by: disposeBag)
        viewModel.author.bind(to: lblAuthor.rx.text).disposed(by: disposeBag)
        viewModel.rating.bind(to: lblRating.rx.text).disposed(by: disposeBag)
        viewModel.date.bind(to: lblDate.rx.text).disposed(by: disposeBag)
        viewModel.content.bind(to: txtContent.rx.text).disposed(by: disposeBag)

        
    }
    
}
