//
//  HabitTableViewCell.swift
//  Habit Tracking
//
//  Created by Abdallah Eslah on 13/01/2025.
//

import UIKit

class HabitTableViewCell: UITableViewCell {
    
    @IBOutlet weak var habitName: UILabel!
    @IBOutlet weak var habitStatus: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layer.cornerRadius = 12
    }
    
    func configureHabitCell(task:TasksEntity){
        habitName.text = task.habitName
        habitStatus.text = task.habitStatus
    }
    
}
