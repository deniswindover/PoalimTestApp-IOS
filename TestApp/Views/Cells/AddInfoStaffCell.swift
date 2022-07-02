//
//  AddInfoStaffCell.swift
//  TestApp
//
//  Created by Denis Bigapps on 01/07/2022.
//

import UIKit
import RxCocoa
import RxSwift


class AddInfoStaffCellViewModel {
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    private var _staff: BehaviorRelay<Details.Staff>
    var profile: Observable<UIImage?> {
        return _staff.flatMap({ RequestManager.picture($0.profile) }).map({ $0?.resizeImage(newSize: CGSize(width: 95, height: 142)) }).observe(on: MainScheduler.asyncInstance)
    }
    var name: Observable<String?> {
        return _staff.map({ $0.name })
    }
    
    // cast
    var character: Observable<String?>?
    // crew
    var job: Observable<String?>?
    
    init(_ staff: Details.Staff){
        
        _staff = BehaviorRelay(value: staff)
        
        if staff is Details.Cast {
            configureCast()
        }else{
            configureCrew()
        }
        
    }
    
    private func configureCast(){
        character = _staff.map({ ($0 as? Details.Cast)?.character })
    }
    
    private func configureCrew(){
        job = _staff.map({ ($0 as? Details.Crew)?.job })
    }
    
}


class AddInfoStaffCell: UITableViewCell {

    // one prototype for 2 types (cast & crew) if is 'cast' lblName = name, if is 'crew' lblName = job & lblCharacter = name
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lblCharacter: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    
    var disposeBag: DisposeBag! = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivProfile.image = nil
        viewModel.disposeBag = DisposeBag()
        disposeBag = DisposeBag()
    }
    
    deinit {
        print("-------DEINIT---------")
        print(self)
        print("-------DEINIT---------")
    }
    
    var viewModel: AddInfoStaffCellViewModel!{
        didSet{ configure() }
    }
    
    
    func configure(){
        
        viewModel.profile.bind(to: ivProfile.rx.image).disposed(by: disposeBag)
        
        if viewModel.character != nil {
            viewModel.character?.bind(to: lblCharacter.rx.text).disposed(by: disposeBag)
            viewModel.name.bind(to: lblName.rx.text).disposed(by: disposeBag)
        }else{
            viewModel.name.bind(to: lblCharacter.rx.text).disposed(by: disposeBag)
            viewModel.job?.bind(to: lblName.rx.text).disposed(by: disposeBag)
        }
        
    }
    
}
