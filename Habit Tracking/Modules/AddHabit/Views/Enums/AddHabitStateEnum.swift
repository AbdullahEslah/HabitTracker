//
//  AddHabitEnum.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import Foundation
enum AddHabitStateEnum<T> {
    case None
    case Loading
    case Success(T)
    case Failure(Error)
}
