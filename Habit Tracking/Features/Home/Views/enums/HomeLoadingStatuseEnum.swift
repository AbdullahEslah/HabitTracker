//
//  HomeLoadingStatuseEnum.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import Foundation
enum HomeLoadingStatuseEnum<T> {
    case None
    case Empty(String)
    case Loading
    case Success(T)
    case Failure(Error)
}
