//
//  HomeVC.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addHabitButton: UIButton!
    
    let placeHolderEmptyLabel = UILabel()

    private lazy var homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        //  register home tableView Habit Nib to show all habits
        self.tableView.register(UINib(nibName: "HabitTableViewCell", bundle: nil), forCellReuseIdentifier: "HabitTableViewCell")
        
        //  floating button action
        self.addHabitButton.addTarget(self, action:#selector(navigateToAddHabit), for: .touchUpInside)
        
        bindAllHabitsToThisView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addHabitButton.layer.shadowOpacity = 0.8
        addHabitButton.layer.shadowOffset = CGSize.zero
        addHabitButton.layer.shadowRadius = 3
        Helper().createGradientView(on: self.view,specificViewHolder: self.view)
    }
    
    private func bindAllHabitsToThisView(){
        homeViewModel.bindingHabitsStatusAddHabitToHomeView  = { [weak self] state in
            guard let self = self else{return}
            DispatchQueue.main.async {
                switch state {
                    
                case .Empty(_):
                    DispatchQueue.main.async {
                        self.tableView.isHidden = true
                        self.placeHolderEmptyLabel.text = "No Habits Added Yet !\n Please Start Adding A New One"
                        self.placeHolderEmptyLabel.textColor = .black
                        self.placeHolderEmptyLabel.textAlignment = .center
                        self.placeHolderEmptyLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                        self.placeHolderEmptyLabel.numberOfLines = 0
                        
                        let labelWidth: CGFloat = self.view.frame.width - 32
                        let labelSize = self.placeHolderEmptyLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
                        
                        let labelX = (self.view.frame.width - labelSize.width) / 2
                        let labelY = (self.view.frame.height - labelSize.height) / 2
                        
                        self.placeHolderEmptyLabel.frame = CGRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height)
                        self.view.addSubview(self.placeHolderEmptyLabel)
                    }
                case .None:
                    break
                    
                case .Loading:
                    //  show loading indicator
                    DispatchQueue.main.async {
                        self.view.activityStartAnimating(activityColor: UIColor.lightGray , backgroundColor: UIColor.black.withAlphaComponent(0.5))
                    }
                case .Success(_):

                    self.placeHolderEmptyLabel.removeFromSuperview()
                        
                        self.tableView.isHidden = false
                        self.view.activityStopAnimating()
                        self.tableView.reloadData()
         
                case.Failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.view.activityStopAnimating()
                        Helper.showAlert(title: "Error", message: error.localizedDescription, in: self)
                    }
                }
            }
        }
    }
    
     @objc private func navigateToAddHabit(){
        let storyboard = UIStoryboard(name: "AddHabitStoryboard", bundle: nil)
        self.present(storyboard.instantiateViewController(withIdentifier: "AddHabitVC"), animated: true)
    }
    
}

extension HomeVC: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let habitCell = tableView.dequeueReusableCell(withIdentifier: "HabitTableViewCell", for: indexPath) as? HabitTableViewCell
        else{return UITableViewCell()}
        let habitItem = homeViewModel.habits[indexPath.row]
        habitCell.configureHabitCell(habit: habitItem)
        return habitCell
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return homeViewModel.habits.count
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 80
    }
    
}
