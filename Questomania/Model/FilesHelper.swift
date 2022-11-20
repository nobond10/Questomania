//
//  FilesHelper.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import Foundation

class FilesHelper {
    static let shared = FilesHelper()
    private let folderName = "Quests"
    private let extName = "que"
    
    private init() {}
    
    func createFolderIfNeeded(at url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("не удалось создать папку по адресу \(url.path)")
            }
        }
    }
    
    func saveQuest(_ quest: Quest, completion: @escaping (Bool) -> Void) {
        let fileName = quest.diskName
        if let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let folderURL = applicationSupport.appendingPathComponent(folderName)
            createFolderIfNeeded(at: folderURL)
            
//            let fileUrl = folderURL.appending(path: "\(fileName).\(extName)")
            let fileUrl = folderURL.appendingPathComponent("\(fileName).\(extName)")
            print("сохранение квеста в \(fileUrl)")
            do {
                let data = try JSONEncoder().encode(quest)
                try data.write(to: fileUrl)
                completion(true)
            } catch {
                print("ошибка при сохранении квеста: \(error.localizedDescription)")
                completion(false)
            }
        } else {
            completion(false)
        }
    }

    func loadQuests(completion: @escaping ([Quest]) -> Void) {
        if let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let folderURL = applicationSupport.appendingPathComponent(folderName)
            createFolderIfNeeded(at: folderURL)
            
            
            let files = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
//            let folderPath = folderURL.path(percentEncoded: false)
//            let files = try? FileManager.default.contentsOfDirectory(atPath: folderPath)
            var quests: [Quest] = []
            for file in files ?? [] {
//                let fullPath = folderPath + file
//                if file.hasSuffix(extName), let questData = FileManager.default.contents(atPath: fullPath) {
                if file.pathExtension == extName, let questData = FileManager.default.contents(atPath: file.path) {
                    do {
                        let quest = try JSONDecoder().decode(Quest.self, from: questData)
                        quests.append(quest)
                    } catch {
                        print("error reading one quest at path \(file)")
                    }
                }
            }
            
            completion(quests)
        } else {
            completion([])
        }
    }

    func deleteQuestWith(diskName: String) {
        if let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let folderURL = applicationSupport.appendingPathComponent(folderName)
            createFolderIfNeeded(at: folderURL)
            
//            let fileUrl = folderURL.appending(path: "\(diskName).\(extName)")
            let fileUrl = folderURL.appendingPathComponent("\(diskName).\(extName)")
            do {
                try FileManager.default.removeItem(at: fileUrl)
            } catch {
                print("ошибка при удалинии квеста по пути \(fileUrl)")
            }
        }
    }

    func urlFor(diskName: String) -> URL? {
        if let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let folderURL = applicationSupport.appendingPathComponent(folderName)
            createFolderIfNeeded(at: folderURL)
            
//            let fileUrl = folderURL.appending(path: "\(diskName).\(extName)")
            let fileUrl = folderURL.appendingPathComponent("\(diskName).\(extName)")
//            if FileManager.default.fileExists(atPath: fileUrl.path(percentEncoded: false)) {
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                return fileUrl
            } else {
                return nil
            }
        }
        return nil
    }

    func handleSharing(tempUrl: URL, completion: @escaping (Bool) -> Void) {
        if let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let folderURL = applicationSupport.appendingPathComponent(folderName)
            createFolderIfNeeded(at: folderURL)
            
            let fileName = tempUrl.lastPathComponent
            let newLocalPath = folderURL.appendingPathComponent(fileName)
//            let newLocalPath = folderURL.appending(path: fileName)
            do {
                try FileManager.default.copyItem(at: tempUrl, to: newLocalPath)
                completion(true)
            } catch {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
}
