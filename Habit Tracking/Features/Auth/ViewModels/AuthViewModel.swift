//
//  AuthViewModel.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

import UIKit

class AuthViewModel {
    
    enum LoginValidationError {
        case missingEmail
        case invalidEmail(String = "please type valid email address")
        case missingPassword
        case invalidPassword(String = "password must be at least 6 characters")
    }
    
    /*  for observing add habit states   */
    var bindingAuthToHomeView : ((AuthEnumState<Any>) -> ())?
    var bindingValidationError:((LoginValidationError)->())?
    var bindingMissingName:((Bool)->())?
    
    func navigateToHome(viewController:UIViewController){
        let storyboard = UIStoryboard(name: "HomeStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func register(name:String?,email:String?,password:String?) async {
        
        guard let username = name, !username.trimmingCharacters(in: .whitespaces).isEmpty else{
            await MainActor.run {
                bindingMissingName?(true)
            }
            return
        }
        
        guard let emailAddress = email, !emailAddress.trimmingCharacters(in: .whitespaces).isEmpty else {
            await MainActor.run {
                bindingValidationError?(.missingEmail)
            }
            return
        }
        
        guard let pass = password, !pass.trimmingCharacters(in: .whitespaces).isEmpty else {
            await MainActor.run {
                bindingValidationError?(.missingPassword)
            }
            return
        }
        
        if !Helper.isValidEmail(emailAddress) {
            await MainActor.run {
                bindingValidationError?(.invalidEmail())
            }
            return
        }
        
        if pass.count < 6 {
            await MainActor.run {
                bindingValidationError?(.invalidPassword())
            }
            return
        }
        
        await MainActor.run {
            bindingAuthToHomeView?(.None)
        }
        
        await MainActor.run {
            bindingAuthToHomeView?(.Loading)
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        //  still in background function
        let body = CreateUserBody(email: emailAddress, password: pass, name: username, avatar: "https://picsum.photos/800")
        
        //  request
        let createdUser = await NetworkManager.shared.request(urlString: APIEndpoints.getURL(endpoint: Auth.register), method: .post,body: body, successType: CreatedUser.self,failureType: APIError.self)
        
        
        await MainActor.run {
            switch createdUser {
            case .success(let user):
                debugPrint("user is", user.email)
                bindingAuthToHomeView?(.Success("User Created Successfully"))
            case .failure(let error):
                debugPrint("error is", error)
                bindingAuthToHomeView?(.Failure(error.message))
            }
        }
    }
    
    
    func login(email:String?,password:String?) async {
        
    
        guard let emailAddress = email, !emailAddress.trimmingCharacters(in: .whitespaces).isEmpty else {
            await MainActor.run {
                bindingValidationError?(.missingEmail)
            }
            return
        }
        
        guard let pass = password, !pass.trimmingCharacters(in: .whitespaces).isEmpty else {
            await MainActor.run {
                bindingValidationError?(.missingPassword)
            }
            return
        }
        
        if !Helper.isValidEmail(emailAddress) {
            await MainActor.run {
                bindingValidationError?(.invalidEmail())
            }
            return
        }
        
        if pass.count < 6 {
            await MainActor.run {
                bindingValidationError?(.invalidPassword())
            }
            return
        }
        
        await MainActor.run {
            bindingAuthToHomeView?(.None)
        }
        
        await MainActor.run {
            bindingAuthToHomeView?(.Loading)
        }
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        //  still in background function
        let body = LoginUserBody(email: emailAddress, password: pass)
        let loggedUser = await NetworkManager.shared.request(urlString: APIEndpoints.getURL(endpoint: Auth.login), method: .post,body: body, successType: LoggedUser.self,failureType: APIError.self)
        
        await MainActor.run {
            switch loggedUser {
            case .success(let user):
                debugPrint("user is", user.access_token)
                bindingAuthToHomeView?(.Success("Logged in Successfully"))
            case .failure(let error):
                debugPrint("error is", error)
                bindingAuthToHomeView?(.Failure(error.message))
            }
        }
    }
    
}
