//
//  LabelCell.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import UIKit

class LabelCell: UITableViewCell {

    @IBOutlet weak var labelText: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.accessoryType = selected ? .checkmark : .none
    }
}
