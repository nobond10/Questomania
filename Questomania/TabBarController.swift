//
//  ViewController.swift
//  Questomania
//
//  Created by Ярослав Косарев on 16.11.2022.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FilesHelper.shared.loadQuests { quests in
            QuestManager.shared.add(quests: quests)
            self.setupUI()
        }
    }
    
    func setupUI() {
        DispatchQueue.main.async {
            let vc1 = UINavigationController(rootViewController: EditorVC())
            vc1.tabBarItem.image = UIImage(systemName: "pencil")
            vc1.tabBarItem.title = "Редактор"
            
            let vc2 = UINavigationController(rootViewController: PlayerVC())
            vc2.tabBarItem.image = UIImage(systemName: "apps.iphone")
            vc2.tabBarItem.title = "Играть"
            
            let vc3 = HelpVC()
            vc3.tabBarItem.image = UIImage(systemName: "questionmark.circle")
            vc3.tabBarItem.title = "Справка"
            
            self.viewControllers = [vc1, vc2, vc3]
        }
    }
}

