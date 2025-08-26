//
//  LoginVC.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

import UIKit

class LoginVC: UIViewController {
    
    private let authViewModel = AuthViewModel()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        bindLoginToTHomeView()
    }
    
    override func viewDidLayoutSubviews() {
        loginButton.layer.shadowOpacity = 0.8
        loginButton.layer.shadowOffset = CGSize.zero
        loginButton.layer.shadowRadius = 3
        if view.layer.sublayers?.contains(where: { $0.name == "gradientLayer" }) == false {
            Helper().createGradientView(on: self.view, specificViewHolder: self.view)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func bindLoginToTHomeView(){
        
        authViewModel.bindingValidationError = { [weak self] error in
            guard let self = self else { return }
                switch error {
                case .missingEmail:
                    Helper.showAlert(title: "Error",message: "Email is missing",in: self)
                case .invalidEmail(let message):
                    Helper.showAlert(title: "Error",message: message,in: self)
                case .missingPassword:
                    Helper.showAlert(title: "Error",message: "Missing Password",in: self)
                case .invalidPassword(let message):
                    Helper.showAlert(title: "Error",message: message,in: self)
                }
        }
        authViewModel.bindingAuthToHomeView  = { [weak self] state in
            guard let self = self else{return}
            
            switch state {
                
            case .None:
                self.view.activityStopAnimating()
                
            case .Loading:
                    self.view.activityStartAnimating(activityColor: UIColor.lightGray , backgroundColor: UIColor.black.withAlphaComponent(0.5))
                
            case .Success(_):
                
                self.authViewModel.navigateToHome(viewController: self)
                self.view.activityStopAnimating()
                
            case.Failure(let error):
                    self.view.activityStopAnimating()
//                let message /*= (error as? NetworkError)?.message ?? error.localizedDescription*/
                Helper.showAlert(title: "Error", message: error, in: self)
            }
        }
    }
        
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        Task {
            await authViewModel.login(email: emailTextField.text, password: passwordTextField.text)
        }
    }
    
    
    @IBAction func cretaeNewAccountButtonPressed(_ sender: Any) {
        
       
        let storyboard = UIStoryboard(name: "AuthStoryboard", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        registerVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(registerVC, animated: true)
        
    }
   
    
}

extension LoginVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
