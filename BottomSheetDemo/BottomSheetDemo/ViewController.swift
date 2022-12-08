//
//  ViewController.swift
//  BottomSheetDemo
//
//  Created by mac on 08/12/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onTapBtnOpenBottomSheet(_ sender: UIButton) {
        let bottomVc = BottomVc()
        bottomVc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            bottomVc.backingImage = self.view.asImage()
            self.present(bottomVc, animated: false)
        }
    }
    
}

