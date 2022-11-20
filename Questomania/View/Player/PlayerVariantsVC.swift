//
//  PlayerVariantsVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import UIKit

class PlayerVariantsVC: CommonPlayerViewController {

    let question: VariantsQuestion
    var selectedVariant: VariantsQuestion.Variant?
    
    init(question: VariantsQuestion, gameSession: GameSession) {
        self.question = question
        super.init(gameSession: gameSession, nibName: "PlayerVariantsVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelQuestion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle(for: question)
        
        labelQuestion.text = question.question

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedVariant = gameSession.getSelectedVariantForQuestion(question)
        updateButtonVisibility()
    }
    
    private func updateButtonVisibility() {
        if let savedVariant = selectedVariant {
            tableView.isUserInteractionEnabled = false
            buttonNext.isHidden = false
            guard let index = question.variants.firstIndex(where: { $0 === savedVariant }) else {
                return
            }
            let row = question.variants.distance(from: question.variants.startIndex, to: index)
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
        } else {
            tableView.isUserInteractionEnabled = true
            if tableView.indexPathForSelectedRow != nil {
                buttonNext.isHidden = false
            } else {
                buttonNext.isHidden = true
            }
        }
    }
    
    @IBAction func buttonNextClicked(_ sender: Any) {
//        if let variant = selectedVariant, let nextQuestion = variant.nextQuestion {
//            showQuestionInPlayerFor(nextQuestion, gameSession: gameSession)
//        }
        
        guard tableView.indexPathForSelectedRow != nil || selectedVariant != nil else {
            let alert = UIAlertController.createOkCancelAlert(title: "Выберите вариант ответа")
            present(alert, animated: true)
            return
        }
        if let selectedVariant = selectedVariant {
            goNext(variant: selectedVariant)
        } else if let selectedRow = tableView.indexPathForSelectedRow?.row {
            let variant = question.variants[selectedRow]
            goNext(variant: variant)
        }
//        if let nextQuestion = variant.nextQuestion {
//            showQuestionInPlayerFor(nextQuestion, gameSession: gameSession)
//            selectedVariant = variant
//            gameSession.addQuestion(question, selectedVariant: variant)
//        } else {
//            let alert = UIAlertController.createOkCancelAlert(title: "На этом ветка закончилась. Но можете пожмякать еще.")
//            present(alert, animated: true)
//        }
    }

    private func goNext(variant: VariantsQuestion.Variant) {
        if let nextQuestion = variant.nextQuestion {
            showQuestionInPlayerFor(nextQuestion, gameSession: gameSession)
            selectedVariant = variant
            gameSession.addQuestion(question, selectedVariant: variant)
        } else {
            let alert = UIAlertController.createOkCancelAlert(title: "На этом ветка закончилась. Но можете пожмякать еще.")
            present(alert, animated: true)
        }
    }
}

extension PlayerVariantsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        question.variants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
        
        let variant = question.variants[indexPath.row]
        cell.labelText.text = variant.answer
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateButtonVisibility()
    }
}
