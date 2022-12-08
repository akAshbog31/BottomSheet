//
//  BottomSheetViewModel.swift
//  BottomSheetDemo
//
//  Created by mac on 08/12/22.
//

import UIKit

class BottomSheetViewModel {
    //MARK: - Enums
    enum CardViewState {
        case expanded
        case normal
    }
    
    //MARK: - Properties
    var cardViewState : CardViewState = .normal
    var cardPanStartingTopConstant : CGFloat = 30.0
    var topConstraint: NSLayoutConstraint
    var cardView: UIView
    var dimmerView: UIView
    var vc: UIViewController
    
    //MARK: - LifeCycle
    init(topConstraint: NSLayoutConstraint, dimmerView: UIView, cardView: UIView, vc: UIViewController) {
        self.vc = vc
        self.dimmerView = dimmerView
        self.cardView = cardView
        self.topConstraint = topConstraint
        
        self.publicInit()
    }
    
    //MARK: - Functions
    
    func publicInit() {
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if let key = UIWindow.key {
            let safeAreaHeight = key.safeAreaLayoutGuide.layoutFrame.size.height
            let bottomPadding = key.safeAreaInsets.bottom
            
            topConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        dimmerView.alpha = 0.0
        
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerViewTapped(_:)))
        dimmerView.addGestureRecognizer(dimmerTap)
        dimmerView.isUserInteractionEnabled = true
        
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false
        vc.view.addGestureRecognizer(viewPan)
    }
    
    func showCard(at state: CardViewState = .normal) {
        vc.view.layoutIfNeeded()
        
        if let key = UIWindow.key {
            let safeAreaHeight = key.safeAreaLayoutGuide.layoutFrame.size.height
            let bottomPadding = key.safeAreaInsets.bottom
            
            if state == .expanded {
                topConstraint.constant = 30.0
            } else {
                topConstraint.constant = (safeAreaHeight + bottomPadding) / 2.0
            }
            
            cardPanStartingTopConstant = topConstraint.constant
        }
        
        let showCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn) {
            self.vc.view.layoutIfNeeded()
        }
        
        showCard.addAnimations {
            self.dimmerView.alpha = 0.7
        }
        
        showCard.startAnimation()
    }
    
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
      hideCardAndGoBack()
    }
    
    @IBAction func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
        let translation = panRecognizer.translation(in: vc.view)
        
        let velocity = panRecognizer.velocity(in: vc.view)
        
        switch panRecognizer.state {
        case .possible:
            break
        case .began:
            cardPanStartingTopConstant = topConstraint.constant
        case .changed:
            if self.cardPanStartingTopConstant + translation.y > 30.0 {
                self.topConstraint.constant = self.cardPanStartingTopConstant + translation.y
            }
            
            dimmerView.alpha = dimAlphaWithCardTopConstraint(value: self.topConstraint.constant)
        case .ended:
            if velocity.y > 1500.0 {
                hideCardAndGoBack()
                return
            }
            
            if let key = UIWindow.key {
                let safeAreaHeight = key.safeAreaLayoutGuide.layoutFrame.size.height
                let bottomPadding = key.safeAreaInsets.bottom
                
                if self.topConstraint.constant < (safeAreaHeight + bottomPadding) * 0.25 {
                    showCard(at: .expanded)
                } else if self.topConstraint.constant < safeAreaHeight - 70 {
                    showCard(at: .normal)
                } else {
                    hideCardAndGoBack()
                }
            }
        case .cancelled:
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    private func hideCardAndGoBack() {
        vc.view.layoutIfNeeded()
        
        if let key = UIWindow.key {
            let safeAreaHeight = key.safeAreaLayoutGuide.layoutFrame.size.height
            let bottomPadding = key.safeAreaInsets.bottom
            
            topConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        let hideCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn) {
            self.vc.view.layoutIfNeeded()
        }
        
        hideCard.addAnimations {
            self.dimmerView.alpha = 0.0
        }
        
        hideCard.addCompletion { position in
            if position == .end {
                if self.vc.presentingViewController != nil {
                    self.vc.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        hideCard.startAnimation()
    }
    
    private func dimAlphaWithCardTopConstraint(value: CGFloat) -> CGFloat {
        let fullDimAlpha : CGFloat = 0.7
        
        if let key = UIWindow.key {
            let safeAreaHeight = key.safeAreaLayoutGuide.layoutFrame.size.height
            let bottomPadding = key.safeAreaInsets.bottom
            
            let fullDimPosition = (safeAreaHeight + bottomPadding) / 2.0
            let noDimPosition = safeAreaHeight + bottomPadding
            
            if value < fullDimPosition {
                return fullDimAlpha
            }
            
            if value > noDimPosition {
                return 0.0
            }

            return fullDimAlpha * 1 - ((value - fullDimPosition) / fullDimPosition)
        } else {
            return fullDimAlpha
        }
    }
   
}

//MARK: - UIView + Extention
extension UIView  {
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
      return renderer.image(actions: { rendererContext in
        layer.render(in: rendererContext.cgContext)
    })
  }
}

//MARK: - UIWindow + Extention
extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
