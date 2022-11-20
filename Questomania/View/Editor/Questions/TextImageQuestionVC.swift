//
//  TextImageQuestionVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit

class TextImageQuestionVC: CommonEditorViewController {

    let question: TextImageQuestion
    var slides: [TextImageQuestion.Question]
    
    init(question: TextImageQuestion, parentQuestion: QuestQuestion? = nil, variantQuestionOption: VariantsQuestion.Variant? = nil, quest: Quest? = nil) {
        self.question = question
        self.slides = question.elements
        super.init(parentQuestion: parentQuestion, variantQuestionOption: variantQuestionOption, quest: quest, childNibName: "TextImageQuestionVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SlideCell", bundle: nil), forCellReuseIdentifier: "SlideCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(buttonSaveClicked))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func buttonSaveClicked() {
        question.elements = slides
        
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
        let alert = UIAlertController.createOkCancelAlert(title: "Вы уверены, что хотите удалить слайд?", okTitle: "Удалить", cancelTitle: "Нет", okCompletion: {
            self.slides.remove(at: button.tag)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    @IBAction func buttonAddSlideClicked(_ sender: Any) {
        let newSlide = TextImageQuestion.Question()
        slides.append(newSlide)
        let vc = SlideVC(slide: newSlide)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TextImageQuestionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        slides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SlideCell", for: indexPath) as! SlideCell
        
        let slide = slides[indexPath.row]
        cell.labelText.text = slide.representation
        
        cell.buttonDelete.removeTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.addTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.tag = indexPath.row
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let slide = slides[indexPath.row]
        let vc = SlideVC(slide: slide)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
