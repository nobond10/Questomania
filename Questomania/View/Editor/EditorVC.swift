//
//  EditorVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit

class EditorVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Квесты"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didSelectAdd))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "QuestCell", bundle: nil), forCellReuseIdentifier: "QuestCell")
        
        NotificationCenter.default.addObserver(forName: .addedNewQuest, object: nil, queue: nil) { [weak self] _ in
            self?.updateQuestsFromDisk()
        }
    }

    private func updateQuestsFromDisk() {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @objc func didSelectAdd() {
        let alert = UIAlertController(title: "Введите название для квеста", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let text = alert.textFields?.first?.text, text.count > 0 {
                self.goToNewQuestWith(name: text)
            }
        }))
        present(alert, animated: true)
    }
    
    func goToNewQuestWith(name: String) {
        let quest = Quest(name: name)
        QuestManager.shared.add(quest: quest)
        let vc = QuestionsVC(quest: quest)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func buttonDeleteTapped(_ button: UIButton) {
        let alert = UIAlertController.createOkCancelAlert(title: "Вы уверены, что хотите удалить квест?", okTitle: "Да", cancelTitle: "Нет", okCompletion: {
            QuestManager.shared.remove(at: button.tag)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    @objc func buttonShareClicked(_ button: UIButton) {
        let quest = QuestManager.shared.quests[button.tag]
        FilesHelper.shared.saveQuest(quest) { [weak self] success in
            DispatchQueue.main.async {
                if success, let url = FilesHelper.shared.urlFor(diskName: quest.diskName) {
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    self?.present(activityViewController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController.createOkCancelAlert(title: "Не удалось сохранить квест")
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

extension EditorVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        QuestManager.shared.quests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestCell", for: indexPath) as! QuestCell
        
        let quest = QuestManager.shared.quests[indexPath.row]
        cell.labelText.text = quest.name
        
        cell.buttonDelete.removeTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.addTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.tag = indexPath.row
        
        cell.buttonShare.removeTarget(self, action: #selector(buttonShareClicked), for: .touchUpInside)
        cell.buttonShare.addTarget(self, action: #selector(buttonShareClicked), for: .touchUpInside)
        cell.buttonShare.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quest = QuestManager.shared.quests[indexPath.row]
        let vc = QuestionsVC(quest: quest)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
