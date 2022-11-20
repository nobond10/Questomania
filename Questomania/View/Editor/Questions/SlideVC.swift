//
//  SlideVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit
import PhotosUI

class SlideVC: UIViewController {

    let slide: TextImageQuestion.Question
    var photoData: [Data]
    
    init(slide: TextImageQuestion.Question) {
        self.slide = slide
        self.photoData = slide.photos
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.makeBorder()
        textView.text = slide.text
        
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(buttonSaveClicked))
        
        self.navigationItem.title = "Слайд"
    }
    
    @objc func buttonSaveClicked() {
        slide.text = textView.text
        slide.photos = photoData
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonAddPhotoClicked(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.selection = .ordered
        configuration.filter = .images
        let vc = PHPickerViewController(configuration: configuration)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func buttonDeleteTapped(_ button: UIButton) {
        let alert = UIAlertController.createOkCancelAlert(title: "Вы уверены, что хотите удалить фото?", okTitle: "Удалить", cancelTitle: "Нет", okCompletion: {
            self.photoData.remove(at: button.tag)
            self.collectionView.reloadData()
        })
        present(alert, animated: true)
    }
}

extension SlideVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let photo = photoData[indexPath.row]
        
        cell.buttonDelete.removeTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.addTarget(self, action: #selector(buttonDeleteTapped), for: .touchUpInside)
        cell.buttonDelete.tag = indexPath.row
        
        cell.imageView.image = UIImage(data: photo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
}

extension SlideVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProviders = results.map(\.itemProvider)
        let dispatchGroup = DispatchGroup()
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let uiimage = image as? UIImage, let data = uiimage.jpegData(compressionQuality: 0.5) {
                        self.photoData.append(data)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.collectionView.reloadData()
            picker.dismiss(animated: true)
        }
    }
}
