//
//  Utils.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import UIKit.UIView
//  for showing loading indicator
extension UIView {
    func activityStartAnimating(activityColor: UIColor, backgroundColor: UIColor) {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = 475647
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)
        
        self.addSubview(backgroundView)
    }
    
    func activityStopAnimating() {
        if let background = viewWithTag(475647){
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
    }
    
    
    //  for showing snackbar view with text and time
    func showSnackbar(message: String, duration: TimeInterval = 3.0, completion: (() -> Void)? = nil) {
        let snackbar = UIView()
        snackbar.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        snackbar.layer.cornerRadius = 8
        snackbar.clipsToBounds = true
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        snackbar.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: snackbar.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: snackbar.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: snackbar.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: snackbar.bottomAnchor, constant: -8)
        ])
        
        self.addSubview(snackbar)
        snackbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            snackbar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            snackbar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            snackbar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        snackbar.alpha = 0
        snackbar.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.3) {
            snackbar.alpha = 1
            snackbar.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                snackbar.alpha = 0
                snackbar.transform = CGAffineTransform(translationX: 0, y: 50)
            }) { _ in
                snackbar.removeFromSuperview()
                completion?()
            }
        }
    }
}

