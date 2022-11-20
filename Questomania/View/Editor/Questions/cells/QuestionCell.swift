//
//  QuestionCell.swift
//  Questomania
//
//  Created by Ярослав Косарев on 18.11.2022.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var buttonNextQuestion: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonNextQuestion.makeBorder()
    }
}
