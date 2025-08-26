//
//  RegisterVC.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

import UIKit

class RegisterVC: UIViewController {
    
    private let authViewModel = AuthViewModel()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.nameTextField.delegate = self
        bindRegisterToHomeView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signupButton.layer.shadowOpacity = 0.8
        signupButton.layer.shadowOffset = CGSize.zero
        signupButton.layer.shadowRadius = 3
        if view.layer.sublayers?.contains(where: { $0.name == "gradientLayer" }) == false {
            Helper().createGradientView(on: self.view, specificViewHolder: self.view)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func bindRegisterToHomeView() {
        authViewModel.bindingMissingName = { [weak self] isMissing in
            guard let self = self else { return }
                if isMissing == true{
                    Helper.showAlert(title: "Error",message: "Name is Missing",in: self)
                }
        }
        
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
        
        //  managing state
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
                Helper.showAlert(title: "Error", message: error, in: self)
            }
        }
        
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        Task {
            await authViewModel.register(name: nameTextField.text, email: emailTextField.text, password: passwordTextField.text)
        }
    }
    
    
    @IBAction func alreadyHaveAnAccountPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
extension RegisterVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
