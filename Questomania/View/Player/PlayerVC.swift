//
//  PlayerVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 16.11.2022.
//

import UIKit

class PlayerVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Выберите квест"
        self.navigationItem.backButtonTitle = "Квесты"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}

extension PlayerVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        QuestManager.shared.quests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as UITableViewCell
        
        let quest = QuestManager.shared.quests[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = quest.name
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quest = QuestManager.shared.quests[indexPath.row]
        if let firstQuestion = quest.firstQuestion {
            showQuestionInPlayerFor(firstQuestion, gameSession: GameSession())
        } else {
            let alert = UIAlertController.createOkCancelAlert(title: "В квесте нет вопросов")
            present(alert, animated: true)
        }
    }
}
