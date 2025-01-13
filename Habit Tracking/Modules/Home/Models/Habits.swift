//
//  Habits.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import Foundation
import FirebaseFirestore

struct Habits :Codable{
    @DocumentID var id: String?
    var habitName  :String?
    var habitStatus:String?
}
