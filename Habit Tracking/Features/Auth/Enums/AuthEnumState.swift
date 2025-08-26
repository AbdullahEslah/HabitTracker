//
//  AuthEnumState.swift
//  Smart Tracking Tasks
//
//  Created by Abdallah Eslah on 25/08/2025.
//

import Foundation
enum AuthEnumState<T> {
    case None
    case Loading
    case Success(T)
    case Failure(String)
}
