//
//  QuestionsVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 18.11.2022.
//

import UIKit

class QuestionsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let quest: Quest
    var questions: [QuestQuestion] = []
    
    init(quest: Quest) {
        self.quest = quest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = quest.name

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "QuestionCell")
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateQuestionFromQuest()
    }
    
    func updateQuestionFromQuest() {
        questions = quest.questionsArray()
        if questions.count > 0 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "opticaldisc"), style: .plain, target: self, action: #selector(saveClicked))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didSelectAdd))
        }
        tableView.reloadData()
    }
    
    @objc func saveClicked() {
        FilesHelper.shared.saveQuest(quest) { [weak self] success in
            DispatchQueue.main.async {
                let title = success ? "Квест сохранен" : "Не удалось сохранить квест"
                let alert = UIAlertController.createOkCancelAlert(title: title)
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc func didSelectAdd() {
        showNextQuestionSelectingType(for: nil, quest: quest)
    }
    
    private func indexOfQuestion(_ question: QuestQuestion) -> Int {
        questions.firstIndex { $0 === question } ?? 0
    }

    @objc func buttonNextQuestionTapped(_ button: UIButton) {
        let question = questions[button.tag]
        showNextQuestionSelectingType(for: question)
    }
    
    @objc func buttonDeleteTapped(_ button: UIButton) {
        let alert = UIAlertController.createOkCancelAlert(title: "Удалить вопрос?", message: "Все дочерние вопросы, если они есть, также будут удалены", okTitle: "Удалить", cancelTitle: "Нет", okCompletion: {
            let question = self.questions[button.tag]
            if question.previousQuestion != nil {
                question.removeFromParent()
            } else if self.quest.firstQuestion === question {
                self.quest.firstQuestion = nil
            } else {
                assertionFailure("сюда код не должен попадать")
            }
            self.updateQuestionFromQuest()
        })
        present(alert, animated: true)
    }
}

extension QuestionsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        
        let question = questions[indexPath.row]
        if let previous = question.previousQuestion {
            cell.labelTitle.text = "#\(indexPath.row), предыдущий #\(indexOfQuestion(previous))"
        } else {
            cell.labelTitle.text = "#\(indexPath.row)"
        }
        
        cell.buttonNextQuestion.isHidden = question.nextQuestion != nil || type(of: question) == VariantsQuestion.self
        cell.buttonNextQuestion.tag = indexPath.row
        cell.buttonNextQuestion.removeTarget(self, action: #selector(buttonNextQuestionTapped), for: .touchUpInside)
        cell.buttonNextQuestion.addTarget(self, action: #selector(buttonNextQuestionTapped), for: .touchUpInside)
        
        cell.buttonDelete.tag = indexPath.row
        cell.buttonDelete.removeTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.addTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        
        cell.labelText.text = question.representation
 
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = questions[indexPath.row]
        
        if let questionPlain = question as? TextImageQuestion {
            let vc = TextImageQuestionVC(question: questionPlain)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let questionVariants = question as? VariantsQuestion {
            let vc = VariantsVC(question: questionVariants)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let questionText = question as? TextQuestion {
            let vc = TextInputQuestionVC(question: questionText)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let questionGeo = question as? GeoQuestion {
            let vc = GeoQuestionVC(question: questionGeo)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
