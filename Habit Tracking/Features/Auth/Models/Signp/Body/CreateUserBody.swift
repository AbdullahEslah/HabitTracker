//
//  CreateUserBody.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

struct CreateUserBody :Encodable{
    let email:String
    let password:String
    let name:String
    let avatar:String
}
