//
//  VariantsVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 17.11.2022.
//

import UIKit

class VariantsVC: CommonEditorViewController {

    let question: VariantsQuestion
    var localVariants: [VariantsQuestion.Variant] = []
    init(question: VariantsQuestion, parentQuestion: QuestQuestion? = nil, variantQuestionOption: VariantsQuestion.Variant? = nil, quest: Quest? = nil) {
        self.question = question
        super.init(parentQuestion: parentQuestion, variantQuestionOption: variantQuestionOption, quest: quest, childNibName: "VariantsVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = question.question
        textView.makeBorder()
        
        tableView.dataSource = self
        localVariants = question.variants
//        tableView.delegate = self
        tableView.register(UINib(nibName: "InputCell", bundle: nil), forCellReuseIdentifier: "InputCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(buttonSaveClicked))
    }
    
    @IBAction func buttonAddVariantClicked(_ sender: Any) {
        localVariants.append(.init())
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func buttonSaveClicked() {
        question.question = textView.text
        question.variants = localVariants
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
    
    @objc func buttonDeleteTapped(_ button: UIButton) {
        let alert = UIAlertController.createOkCancelAlert(title: "Вы уверены, что хотите удалить вариант ответа?", message: "Все дочерние вопросы, если они есть, также будут удалены", okTitle: "Да", cancelTitle: "Нет", okCompletion: {
            self.localVariants.remove(at: button.tag)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    @objc func createNextQuestionTapped(_ button: UIButton) {
        let variant = localVariants[button.tag]
        if let nextQuestion = variant.nextQuestion {
            let title = "К этому вопросу уже создан следующий вопрос: " + nextQuestion.representation
            let alert = UIAlertController.createOkCancelAlert(title: title)
            present(alert, animated: true)
        } else {
            showNextQuestionSelectingType(for: question, variantQuestionOption: variant)
        }
    }
}

extension VariantsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        localVariants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as! InputCell
        
        let variant = localVariants[indexPath.row]
        cell.textField.text = variant.answer
        cell.textField.tag = indexPath.row
        cell.textField.delegate = self
        
        let image = variant.nextQuestion == nil ? UIImage(systemName: "plus") : UIImage(systemName: "info.circle.fill")
        cell.buttonPlus.setImage(image, for: .normal)
        
        cell.buttonDelete.removeTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.addTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.tag = indexPath.row
        
        cell.buttonPlus.removeTarget(self, action: #selector(createNextQuestionTapped), for: .touchUpInside)
        cell.buttonPlus.addTarget(self, action: #selector(createNextQuestionTapped), for: .touchUpInside)
        cell.buttonPlus.tag = indexPath.row
        
        return cell
    }
}

extension VariantsVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            localVariants[textField.tag].answer = updatedText
        }
        return true
    }
}
