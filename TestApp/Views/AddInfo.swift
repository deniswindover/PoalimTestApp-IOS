//
//  AddInfo.swift
//  TestApp
//
//  Created by Denis Bigapps on 01/07/2022.
//

import UIKit
import RxCocoa
import RxSwift

class AddInfo: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var tblContent: UITableView!
    
    let disposeBag = DisposeBag()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        contentView = loadViewFromNib()
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    private func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

}
