//
//  HomeVC.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import UIKit
import CoreData
import Reachability

class HomeVC: UIViewController {
    
    @IBOutlet weak var noHabitsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addHabitButton: UIButton!
    
    var reachability : Reachability?
    private var homeViewModel :HomeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        
        reachability = try! Reachability()
        homeViewModel = HomeViewModel(reachability: reachability!)
        
        //  floating button action
        self.addHabitButton.addTarget(self, action:#selector(navigateToAddHabit), for: .touchUpInside)
        
        homeViewModel?.fetchedhResultController.delegate = self
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
          try reachability?.startNotifier()
        }catch{
          print("could not start reachability notifier")
        }
        bindAllHabitsToThisView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addHabitButton.layer.shadowOpacity = 0.8
        addHabitButton.layer.shadowOffset = CGSize.zero
        addHabitButton.layer.shadowRadius = 3
        if view.layer.sublayers?.contains(where: { $0.name == "gradientLayer" }) == false {
            Helper().createGradientView(on: self.view, specificViewHolder: self.view)
        }
    }
    
    fileprivate func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        //  register home tableView Habit Nib to show all habits
        self.tableView.register(UINib(nibName: "HabitTableViewCell", bundle: nil), forCellReuseIdentifier: "HabitTableViewCell")
    }
    
    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi:

          homeViewModel?.fetchTasksFromFirestore { tasks in
              if let tasks = tasks {
                  self.homeViewModel?.clearCoreDataItems()
                  self.homeViewModel?.saveInCoreDataWith(array: tasks)
                  debugPrint("connected to internet")
                  debugPrint("tasksFromFirestore are",tasks)
              }else {
                  debugPrint("No tasks",tasks ?? [])
              }
          }
          
          DispatchQueue.main.async {
              self.view.showSnackbar(
                  message: "Tasks Now Are Coming From Cloud. Start Adding Yours!",
                  duration: 5)
          }
          print("Reachable via WiFi")
          
      case .cellular:
          homeViewModel?.fetchTasksFromFirestore{ tasks in
              if let tasks = tasks {
                  self.homeViewModel?.clearCoreDataItems()
                  self.homeViewModel?.saveInCoreDataWith(array: tasks)
                  debugPrint("connected to internet")
                  debugPrint("tasksFromFirestore are",tasks)
              }else {
                  debugPrint("No tasks",tasks ?? [])
              }
          }
          
          DispatchQueue.main.async {
              self.view.showSnackbar(
                  message: "Tasks Now Are Coming From Cloud. Start Adding Yours!",
                  duration: 5)
          }
          print("Reachable via Cellular")
          
          
      case .unavailable:
          homeViewModel?.fetchOffline()
          DispatchQueue.main.async {
              self.view.showSnackbar(
                message: "You Are Currently Getting Your Tasks Offline",
                duration: 5
              )
          }
          
        print("Network not reachable")
      }
    }
    
    
    private func bindAllHabitsToThisView() {
        
        homeViewModel?.bindingHabitsStatusAddHabitToHomeView  = { [weak self] state in
            guard let self = self else{return}
            
            switch state {
            case .None:
                self.view.activityStopAnimating()
                
            case .Empty(let empty):
                self.tableView.isHidden = true
                self.noHabitsLabel.isHidden = false
                noHabitsLabel.text = empty
                self.view.activityStopAnimating()
                
            case .Loading:
                self.view.activityStartAnimating(activityColor: UIColor.lightGray , backgroundColor: UIColor.black.withAlphaComponent(0.5))
                
            case .Success(_):
                if homeViewModel?.fetchedhResultController.fetchedObjects?.isEmpty == false  {
                    self.noHabitsLabel.isHidden = true
                    self.tableView.isHidden = false
                }else{
                    self.noHabitsLabel.isHidden = false
                    self.tableView.isHidden = true
                }
                self.view.activityStopAnimating()
                self.tableView.reloadData()
                
            case.Failure(let error):
                
                self.view.activityStopAnimating()
                Helper.showAlert(title: "Error", message: error.localizedDescription, in: self)
            }
        }
        
        homeViewModel?.bindingDeletingHabit  = { [weak self] isDeleted in
            guard let self = self else{return}
            if isDeleted {
                self.view.activityStopAnimating()
                self.view.showSnackbar(message: "Habit Deleted Successfully", duration: 5)
                self.tableView.reloadData()
            }else{
                self.view.showSnackbar(message: "Something Went Wrong. Please Try Again Later", duration: 5)
            }
        }
        
        
        self.homeViewModel?.bindingSavingDataFromFirestoreToLocalStorage  = { [weak self] saved in
            guard let self = self else{return}
            if saved {
                self.view.activityStopAnimating()
                self.tableView.reloadData()
            }
        }
        
        
        homeViewModel?.bindingFetchingFromLocalStorage  = { [weak self] fetched in
            guard let self = self else{return}
            if fetched {
                self.noHabitsLabel.isHidden = true
                self.tableView.isHidden = false
                self.view.activityStopAnimating()
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    @objc private func navigateToAddHabit(){
        let storyboard = UIStoryboard(name: "AddHabitStoryboard", bundle: nil)
        self.present(storyboard.instantiateViewController(withIdentifier: "AddHabitVC"), animated: true)
    }
    
}

extension HomeVC: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tasksCell = tableView.dequeueReusableCell(withIdentifier: "HabitTableViewCell", for: indexPath) as? HabitTableViewCell
        else{return UITableViewCell()}
        if let obj = homeViewModel?.fetchedhResultController.object(at: indexPath) as? TasksEntity{
            tasksCell.configureHabitCell(task: obj)
        }
        
        
        return tasksCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = homeViewModel?.fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

            //  delete from core data and firestore
        if editingStyle == .delete {
            if let obj = homeViewModel?.fetchedhResultController.object(at: indexPath) as? TasksEntity {
                    //  if passed id is nil then skip deleting from firestore
                    homeViewModel?.deleteHabitFromFirestore(habitID: obj.id ?? "")
                    homeViewModel?.deleteFromLocalStorage(task: obj)
                }
        }
    }
    
}

extension HomeVC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            
        case .update:
                    if let indexPath = indexPath,
                       let cell = tableView.cellForRow(at: indexPath) as? HabitTableViewCell,
                       let obj = controller.object(at: indexPath) as? TasksEntity {
                        cell.configureHabitCell(task: obj)
                    }
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
