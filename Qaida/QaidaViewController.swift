//
//  QaidaViewController.swift
//  Menu_FYP
//
//  Created by Bilal Shahid on 11/8/18.
//  Copyright © 2018 Bilal Shahid. All rights reserved.
//

import UIKit

class QaidaViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var CollectionViwe: UICollectionView!
    var student: User?
    let reuseIdentifier = "QaidaCell"
    var QaidaData = Qaida()
    var activities = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9242517352, green: 0.9300937653, blue: 0.9034610391, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        QaidaData = getQaidaData()
        activities = QaidaData.getActivities()
        self.title="Qaida"
        setup()
    }
    func setup() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing=10
        layout.scrollDirection = .vertical
        CollectionViwe!.collectionViewLayout = layout
        CollectionViwe?.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! QaidaCollectionViewCell
        cell.button.setTitle(activities[indexPath.row], for: .normal)
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("hello")
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "LessonView") as! LessonsViewController
        destinationVC.activityIndex = indexPath.row
        destinationVC.student = self.student
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/3)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.CollectionViwe.collectionViewLayout.invalidateLayout()
    }
}
