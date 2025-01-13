//
//  AddHabitViewModel.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import Foundation
import FirebaseFirestore

class AddHabitViewModel{
    
    let db = Firestore.firestore()
    
    /*  for observing add habit states   */
    var bindingAddHabitStatusAddHabitToHomeView : ((AddHabitStateEnum<Any>) -> ())?
    
    func addHabit(habitName:String, habitStatus:String) {
        bindingAddHabitStatusAddHabitToHomeView?(.Loading)
        let collectionRef = db.collection("habits")
        let habit = Habits(habitName: habitName, habitStatus: habitStatus)
        do {
             try collectionRef.addDocument(from: habit)
            bindingAddHabitStatusAddHabitToHomeView?(.Success("Habit Added Successfully"))
        } catch{
            print(error)
            bindingAddHabitStatusAddHabitToHomeView?(.Failure(error))
        }
        
    }
}
