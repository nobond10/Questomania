//
//  GeoPlayerVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import UIKit

class GeoPlayerVC: CommonPlayerViewController {

    @IBOutlet weak var buttonNext: UIButton!
    let question: GeoQuestion
    let locationHelper: LocationHelper
    
    init(question: GeoQuestion, gameSession: GameSession) {
        self.question = question
        self.locationHelper = LocationHelper(lat: question.lat, lon: question.lon)
        super.init(gameSession: gameSession, nibName: "GeoPlayerVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle(for: question)
        
        locationHelper.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationHelper.stop()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let isPassed = gameSession.contains(question: question)
        if !isPassed {
            locationHelper.start()
        }
        buttonNext.isHidden = !isPassed
    }
    
    @IBAction func buttonNextClicked(_ sender: Any) {
        goNext()
    }

    private func goNext() {
        locationHelper.delegate = nil
        gameSession.addQuestion(question)
        showNextQuestionInPlayerFor(question, gameSession: gameSession)
    }
}

extension GeoPlayerVC: LocationHelperDelegate {
    func userAtDesiredLocation() {
        locationHelper.delegate = nil
        let alert = UIAlertController.createOkCancelAlert(title: "Поздравляем", message: "Вы пришли в нужное место", okTitle: "ОК", okCompletion: { [weak self] in
            self?.goNext()
        })
        present(alert, animated: true)
    }
}
