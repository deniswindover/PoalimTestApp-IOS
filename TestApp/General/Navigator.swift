//
//  Navigator.swift
//  TestApp
//
//  Created by Denis Bigapps on 02/07/2022.
//

import Foundation
import UIKit

class Navigator {
    static let shared = Navigator()
    private let main = UIApplication.shared.keyWindow!.rootViewController as! UINavigationController
    
    func toDetails(_ movie: Movie){
        let view = _detailsView
        view.viewModel = DetailsViewModel(movie)
        main.pushViewController(view, animated: true)
    }
    
    func back(){
        main.popViewController(animated: true)
    }
    
    private var _detailsView: DetailsView {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsView") as! DetailsView
    }
}
