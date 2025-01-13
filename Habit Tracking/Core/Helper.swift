//
//  Utils.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import UIKit.UIView

class Helper{
    func createGradientView(on specificView:UIView,specificViewHolder:UIView){
        
        //  first gradientView
        let targetedView = UIView(frame: CGRectMake(0, 0, specificView.bounds.width, specificView.bounds.height))
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = targetedView.bounds
        gradientLayer.colors = [UIColor.black.cgColor,UIColor(red:92/255 , green: 94/255, blue: 91/255, alpha: 1).cgColor, UIColor(red:243/255 , green: 217/255, blue: 148/255, alpha: 1).cgColor, UIColor(red:241/255 , green: 228/255, blue: 232/255, alpha: 1).cgColor]
        targetedView.layer.insertSublayer(gradientLayer, at:0)
        specificViewHolder.layer.insertSublayer(targetedView.layer, at: 0)
        
    }
    
    // show alert message to the user
    static func showAlert(title: String, message: String, in vc: UIViewController) {
        
        // creating alertController; creating button to the alertController; assigning button to alertController; presenting alert controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)
    }
}
