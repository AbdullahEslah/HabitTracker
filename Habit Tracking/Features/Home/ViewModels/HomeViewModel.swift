//
//  HomeViewModel.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import Foundation
import FirebaseFirestore
import CoreData
import Reachability

class HomeViewModel{
    
    /*  for observing add habit states   */
    var bindingHabitsStatusAddHabitToHomeView : ((HomeLoadingStatuseEnum<Any>) -> ())?
    var bindingDeletingHabit:((Bool)->())?
    var bindingSavingDataFromFirestoreToLocalStorage:((Bool)->())?
    var bindingFetchingFromLocalStorage:((Bool)->())?
    /********************************/
    
    
    //  used for fetching & delete from firestore
    let db = Firestore.firestore()
    
    private let reachability : Reachability
    
    
    //  data came from coredata
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: TasksEntity.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        return frc
    }()
    
    init(reachability:Reachability) {
        self.reachability = reachability
    }


    func clearCoreDataItems() {
        do {
            let context = CoreDataManager.shared.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TasksEntity")
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataManager.shared.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
    
    
    private func createEntityFrom(habitsModel: Habits) -> NSManagedObject? {
        //  the context where our data will be handled
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        guard let tracksEntity = NSEntityDescription.insertNewObject(forEntityName: "TasksEntity", into: context) as? TasksEntity else {
            return nil
        }
        
        tracksEntity.id = habitsModel.id
        tracksEntity.habitName = habitsModel.habitName
        tracksEntity.habitStatus = habitsModel.habitStatus
        
        return tracksEntity
    }
  
    
    func saveInCoreDataWith(array: [Habits]) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            try self.fetchedhResultController.performFetch()

            array.forEach { habit in
                    _ = self.createEntityFrom(habitsModel: habit)
                    debugPrint("➕ Inserted new task with id \(habit.id ?? "")")
            }
            
            try context.save()
            debugPrint("✅ Save finished successfully")
            Task { @MainActor in
                self.bindingSavingDataFromFirestoreToLocalStorage?(true)
            }
            
        } catch {
            Task { @MainActor in
                self.bindingHabitsStatusAddHabitToHomeView?(.Failure(error))
            }
            debugPrint("❌ Fetch error: \(error.localizedDescription)")
        }
    }

    
    
    func fetchHabits() {
        
        //  show loading
        Task { @MainActor in
            bindingHabitsStatusAddHabitToHomeView?(.Loading)
        }
        
        ///  1=>save object with different id or any field than we have in firestore data from firestore to coredata
        //  2=>show snackbar that we syncing local tasks to cloud
        if reachability.connection != .unavailable {
            
            self.fetchTasksFromFirestore{ tasks in
                if let tasks = tasks {
                    self.saveInCoreDataWith(array: tasks)
                    debugPrint("connected to internet")
                    debugPrint("tasksFromFirestore are",tasks)
                }else {
                    debugPrint("No tasks",tasks ?? [])
                }
            }
        }
        
        //  1=>check if coredata is not empty
        //  2=>fetch them
        //  3=>show snackbar says fetching tasks offline
        if reachability.connection == .unavailable {
            self.fetchOffline()
        }
        
        
    }
    
    
    
     func fetchOffline() {
         Task { @MainActor in
             bindingHabitsStatusAddHabitToHomeView?(.Loading)
         }
        //  fetch from coredata
         do {
             try self.fetchedhResultController.performFetch()

             if let localHabits = self.fetchedhResultController.fetchedObjects , !localHabits.isEmpty{
                 
                 debugPrint("local taskst are",localHabits)
                 
                 Task { @MainActor in
                     self.bindingFetchingFromLocalStorage?(true)
                 }
                 
             }else{
                 Task { @MainActor in
                     self.bindingHabitsStatusAddHabitToHomeView?(.Empty("No Tasks Found Offline.\n Start Adding A New One To Appear Here"))
                 }
             }

            
        } catch let error  {
            debugPrint("ERROR: \(error)")
            Task { @MainActor in
                
                self.bindingHabitsStatusAddHabitToHomeView?(.Failure(error))
            }
        }
    }
    
    func fetchTasksFromFirestore(completion: @escaping ([Habits]?) -> Void) {
        Task { @MainActor in
            bindingHabitsStatusAddHabitToHomeView?(.Loading)
        }
        
        db.collection("habits").addSnapshotListener { querySnapshot, error in
            if let error = error {
                Task { @MainActor in
                    self.bindingHabitsStatusAddHabitToHomeView?(.Failure(error))
                }
                print("Error fetching documents: \(error)")
                
                completion(nil)
            }
            
            if querySnapshot?.isEmpty == true{
                debugPrint("No data found from firestore")
                Task { @MainActor in
                    self.bindingHabitsStatusAddHabitToHomeView?(.Empty("No tasks added yet.\n start adding a new one to appear here"))
                }
                
                completion(nil)
            }
            
            
            do {
                
                //  if there are data came from firestor
                if let snapShot = querySnapshot{
                    let habits: [Habits] = try snapShot.documents.compactMap { document in
                        var habit = try document.data(as: Habits.self)
                        habit.id = document.documentID
                        return habit
                    }
                    debugPrint("tasks are",habits)
                    
                    
                    Task { @MainActor in
                        //  make success if not empty to stop loading and reloadTableView
                        self.bindingHabitsStatusAddHabitToHomeView?(.Success(habits))
                    }
                    completion(habits)
                }
                
            } catch {
                print("Error decoding habis: \(error)")
                completion(nil)
                Task { @MainActor in
                    self.bindingHabitsStatusAddHabitToHomeView?(.Failure(error))
                }
            }
        }
    }
    
    //  deletion
    func deleteHabitFromFirestore(habitID: String?) {
        guard let id = habitID, !id.isEmpty else {
                print("❌ Error: habitID is empty. Can't delete from Firestore.")
                return
            }
        db.collection("habits").document(id).delete { error in
            if let _ = error {
                Task{ @MainActor in
                    self.bindingDeletingHabit?(false)
                }
            } else {
                Task{ @MainActor in
                    self.bindingDeletingHabit?(true)
                }
            }
        }
        
    }
    
    func deleteFromLocalStorage(task: TasksEntity) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.delete(task)
        do {
            try context.save()
            Task{ @MainActor in
                self.bindingDeletingHabit?(true)
            }
        } catch {
            print("❌ Error deleting: \(error)")
        }
    }

}
