//
//  AddHabitViewModel.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import Foundation
import FirebaseFirestore
import Reachability
import CoreData

class AddHabitViewModel{
    
    private let reachability : Reachability
    
    /*  for observing add habit states   */
    var bindingAddHabitStatusAddHabitToHomeView : ((AddHabitStateEnum<Any>) -> ())?
    var bindingSavingDataToLocalStorage:((Bool)->())?
    
    init(reachability:Reachability) {
        self.reachability = reachability
    }
    
    
    private func createEntityFrom(habitsModel: Habits) -> Bool? {
        var isTaskCreated = false
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let tracksEntity = NSEntityDescription.insertNewObject(
            forEntityName: "TasksEntity",
            into: context
        ) as? TasksEntity  {
            tracksEntity.id = habitsModel.id
            tracksEntity.habitName = habitsModel.habitName
            tracksEntity.habitStatus = habitsModel.habitStatus
        }
        
        do {
            try context.save()
            isTaskCreated = true
            Task { @MainActor in
                self.bindingSavingDataToLocalStorage?(true)
            }
        } catch let error {
            isTaskCreated = false
            Task { @MainActor in
                self.bindingAddHabitStatusAddHabitToHomeView?(.Failure(error))
            }
            debugPrint(error)
        }
        return isTaskCreated
    }
    
    func addHabit(habitName:String, habitStatus:String)  {
        
        self.bindingAddHabitStatusAddHabitToHomeView?(.Loading)
        
        if reachability.connection != .unavailable {
            
            let db = Firestore.firestore()
            let collectionRef = db.collection("habits")
            do {
                let habit = Habits(habitName: habitName, habitStatus: habitStatus)
                try collectionRef.addDocument(from: habit)
                Task { @MainActor in
                    self.bindingAddHabitStatusAddHabitToHomeView?(.Success("Task Added Successfully And Synced To Cloud"))
                }
            } catch{
                debugPrint(error)
                Task { @MainActor in
                    self.bindingAddHabitStatusAddHabitToHomeView?(.Failure(error))
                }
            }
        }
        
        if reachability.connection == .unavailable {
            
            
            let habit = Habits(
                habitName: habitName, habitStatus: habitStatus)
                let saveToCoreData = self.createEntityFrom(habitsModel: habit)
            
            if (saveToCoreData != nil) {
                debugPrint("added a new task")
            }else{
                debugPrint("failed to add a new task")
                
            }
        }
        
    }
}
