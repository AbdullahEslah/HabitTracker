//
//  ViewController.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import UIKit

class AddHabitVC: UIViewController {
    
    lazy var addHabitViewModel = AddHabitViewModel()
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var addHabitButton: UIButton!
    @IBOutlet weak var habitNameTextField: UITextField!
    @IBOutlet weak var menuButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        Helper().createGradientView(on: self.view, specificViewHolder: self.view)
        
        
    }
    
    func checkWhetherDataAddedOrNot(){
        addHabitViewModel.bindingAddHabitStatusAddHabitToHomeView  = { [weak self] state in
            guard let self = self else{return}
            
            switch state {
            case .None:
                break
                
            case .Loading:
                //  show loading indicator
                self.view.activityStartAnimating(activityColor: UIColor.lightGray , backgroundColor: UIColor.black.withAlphaComponent(0.5))
                
            case .Success(_):
                DispatchQueue.main.async{
                    self.view.showSnackbar(message: "Habit Added Successfully", duration: 5)
                }
               
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    
                    self.view.activityStopAnimating()
                    self.dismiss(animated: true)
                }
                
                
            case.Failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.view.activityStopAnimating()
                    Helper.showAlert(title: "Error", message: error.localizedDescription, in: self)
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
        addHabitViewModel.addHabit(habitName: habitNameTextField?.text ?? "", habitStatus: menuButton.menu?.selectedElements.first?.title ?? "")
    }
    
}
