//
//  BootomVc.swift
//  BottomSheetDemo
//
//  Created by mac on 08/12/22.
//

import UIKit

class BottomVc: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    var viewModel: BottomSheetViewModel!
    var backingImage: UIImage?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.viewModel = BottomSheetViewModel(topConstraint: self.cardViewTopConstraint, dimmerView: self.dimmerView, cardView: self.cardView, vc: self)
        }
        backingImageView.image = backingImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.showCard()
    }
    
    //MARK: - @IBAction
    
    //MARK: - Functions
    
}


