//
//  PlayerTextImageVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import UIKit

class PlayerTextImageVC: CommonPlayerViewController {

    let question: TextImageQuestion
    
    init(question: TextImageQuestion, gameSession: GameSession) {
        self.question = question
        super.init(gameSession: gameSession, nibName: "PlayerTextImageVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle(for: question)

        pageControl.numberOfPages = question.elements.count
        pageControl.isHidden = question.elements.count == 1
        
        updateButtonNext(currentPage: 0)
    }
    
    private func updateButtonNext(currentPage: Int) {
        let maxPageIndex = question.elements.count - 1
        let questionWasSeen = questionWasSeen(question: question)
        buttonNext.isEnabled = questionWasSeen || currentPage == maxPageIndex
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "TextImagePlayerCell", bundle: nil), forCellWithReuseIdentifier: "TextImagePlayerCell")
    }

    var layoutWasSetup = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !layoutWasSetup {
            layoutWasSetup = true
            configureCollectionView()
        }
    }
    
    @IBAction func buttonNextClicked(_ sender: Any) {
        gameSession.addQuestion(question)
        showNextQuestionInPlayerFor(question, gameSession: gameSession)
    }
}

extension PlayerTextImageVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        question.elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextImagePlayerCell", for: indexPath) as! TextImagePlayerCell
        
        let slide = question.elements[indexPath.row]
        if slide.text.count > 0 {
            cell.labelText.text = slide.text
            cell.labelText.isHidden = false
        } else {
            cell.labelText.isHidden = true
        }
        
        cell.stackView.arrangedSubviews.filter{ $0.tag != 1 }.forEach { view in
            view.removeFromSuperview()
//            cell.stackView.removeArrangedSubview(view)
        }

        for photoData in slide.photos {
            if let image = UIImage(data: photoData) {
                let imageView = UIImageView(image: image)
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFit
                
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: image.size.height/image.size.width).isActive = true

                cell.stackView.addArrangedSubview(imageView)
            }
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        pageControl.currentPage = currentPage
        updateButtonNext(currentPage: currentPage)
    }
}
