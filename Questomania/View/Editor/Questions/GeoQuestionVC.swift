//
//  GeoQuestion.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit

class GeoQuestionVC: CommonEditorViewController {
    
    let question: GeoQuestion
    init(question: GeoQuestion, parentQuestion: QuestQuestion? = nil, variantQuestionOption: VariantsQuestion.Variant? = nil, quest: Quest? = nil) {
        self.question = question
        super.init(parentQuestion: parentQuestion, variantQuestionOption: variantQuestionOption, quest: quest, childNibName: "GeoQuestionVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var textFieldLat: TextFieldWithLeftView!
    @IBOutlet weak var textFieldLon: TextFieldWithLeftView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldLat.text = "\(question.lat)"
        textFieldLon.text = "\(question.lon)"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(buttonSaveClicked))
    }
    
    @objc func buttonSaveClicked() {
        question.lat = (textFieldLat.text as? NSString)?.doubleValue ?? 0
        question.lon = (textFieldLon.text as? NSString)?.doubleValue ?? 0
        
        if let parentQuestion = parentQuestion {
            parentQuestion.nextQuestion = question
            question.previousQuestion = parentQuestion
        }
        if let variantQuestionOption = variantQuestionOption {
            variantQuestionOption.nextQuestion = question
        }
        if let quest = quest {
            quest.firstQuestion = question
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}
