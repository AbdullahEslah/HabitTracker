//
//  HomeViewModel.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import Foundation
import FirebaseFirestore

class HomeViewModel{
    
    init(){
        fetchHabitsFromFirestore()
    }
    
    //  array of habits
    private lazy var habitsArray = [Habits]()
    //  getter to prevent adding to this array from outsider classes
    var habits: [Habits] {
        habitsArray
    }
    
    /*  for observing add habit states   */
    var bindingHabitsStatusAddHabitToHomeView : ((HomeLoadingStatuseEnum<Any>) -> ())?
    
    func fetchHabitsFromFirestore() {
        bindingHabitsStatusAddHabitToHomeView?(.Loading)
        Firestore.firestore().collection("habits").addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                //return
            }
            
                
            
            if querySnapshot?.isEmpty == true{
                print("No data found")
                self.bindingHabitsStatusAddHabitToHomeView?(.Empty("No habits found."))
                //return
            }
            
            do {
                if let snapShot = querySnapshot{
                    let habits: [Habits] = try snapShot.documents.compactMap { document in
                        var habit = try document.data(as: Habits.self)
                        habit.id = document.documentID
                        return habit
                    }
                    print("habits are",habits)
                    self.habitsArray = habits
                    self.bindingHabitsStatusAddHabitToHomeView?(.Success(habits))
                }
            } catch {
                self.bindingHabitsStatusAddHabitToHomeView?(.Failure(error))
                print("Error decoding habis: \(error)")
            }
        }
    }
    
}
