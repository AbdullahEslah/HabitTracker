//
//  ViewController.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import UIKit
import Reachability

class AddHabitVC: UIViewController {
    private var reachability : Reachability?
    private var addHabitViewModel :AddHabitViewModel?
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var addHabitButton: UIButton!
    @IBOutlet weak var habitNameTextField: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.habitNameTextField.delegate = self
        
        reachability = try! Reachability()
        addHabitViewModel = AddHabitViewModel(reachability: reachability!)
        checkWhetherDataAddedOrNot()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /**
         shadow for dismiss and addHabit button
         we can add make custom class for
         UIButton but used this way instead
         **/
        addHabitButton.layer.shadowOpacity = 0.4
        addHabitButton.layer.shadowOffset = CGSize.zero
        addHabitButton.layer.shadowRadius = 3
        
        dismissButton.layer.shadowColor = UIColor.white.cgColor
        dismissButton.layer.shadowOpacity = 0.6
        dismissButton.layer.shadowOffset = CGSize.zero
        dismissButton.layer.shadowRadius = 3
        
        if view.layer.sublayers?.contains(where: { $0.name == "gradientLayer" }) == false {
            Helper().createGradientView(on: self.view, specificViewHolder: self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
           do{
             try reachability?.startNotifier()
           }catch{
             print("could not start reachability notifier")
           }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi:
          DispatchQueue.main.async {
              self.view.showSnackbar(
                  message: "Start Adding Your Tasks To Cloud!",
                  duration: 5)
          }
          print("Reachable via WiFi")
      case .cellular:
          DispatchQueue.main.async {
              self.view.showSnackbar(
                  message: "Start Adding Your Tasks To Cloud!",
                  duration: 5)
          }
          print("Reachable via Cellular")
      case .unavailable:
          DispatchQueue.main.async {
              self.view.showSnackbar(
                  message: "Don't Worry. You Can Add Your Task Locally.",duration: 5)
              
          }
          
        print("Network not reachable")
      }
    }
    
    func checkWhetherDataAddedOrNot(){
        addHabitViewModel?.bindingAddHabitStatusAddHabitToHomeView  = { [weak self] state in
            guard let self = self else{return}
            
            switch state {
            case .None:
                self.view.activityStopAnimating()
                
            case .Loading:
                self.view.activityStartAnimating(activityColor: UIColor.lightGray , backgroundColor: UIColor.black.withAlphaComponent(0.5))
                
            case .Success(let message):

                let msg = message as! String
                self.view.activityStopAnimating()
                
                // Show Snackbar
                self.view.showSnackbar(message: msg, duration: 2.5) {
                    self.dismiss(animated: true)
                }

                
            case.Failure(let error):
                self.view.activityStopAnimating()
                Helper.showAlert(title: "Error", message: "\(error)", in: self)
                
                
            }
        }
        
        addHabitViewModel?.bindingSavingDataToLocalStorage = { [weak self] saved in
            guard let self = self else{return}
            if saved{
                self.view.activityStopAnimating()
                self.view.showSnackbar(
                    message: "Task Added Successfully And Saved Offline",
                    duration: 3
                ) {
                    self.dismiss(animated: true)
                }
            }
        }
        
    }

    @IBAction func dismissButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func chooseHabitStatusButtonClicked(_ sender: Any) {
        print(menuButton.menu?.selectedElements.first?.title ?? "")
    }
    
    @IBAction func addHabitButtonClicked(_ sender: Any) {
        
        //  validation for habit input
        if habitNameTextField.text?.isEmpty == true || habitNameTextField.text == nil {
            Helper.showAlert(title: "Empty Field !", message: "Please Type Your Habit..", in: self)
            return
        }
        //  then add to firestore
        addHabitViewModel?.addHabit(habitName: habitNameTextField?.text ?? "", habitStatus: menuButton.menu?.selectedElements.first?.title ?? "")
    }
    
}

extension AddHabitVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


