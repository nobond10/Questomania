//
//  QuestManager.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import Foundation

class QuestManager {
    static let shared = QuestManager()
    private(set) var quests: [Quest] = []
    private init() {}

    func add(quest: Quest) {
        quests.append(quest)
    }
    
    func add(quests: [Quest]) {
        self.quests = quests
    }

    func remove(quest questForRemove: Quest) {
        quests.removeAll { quest in
            questForRemove === quest
        }
        FilesHelper.shared.deleteQuestWith(diskName: questForRemove.diskName)
    }

    func remove(at index: Int) {
        let quest = quests[index]
        FilesHelper.shared.deleteQuestWith(diskName: quest.diskName)
        quests.remove(at: index)
    }
}
