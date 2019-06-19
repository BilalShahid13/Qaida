//
//  LessonsViewController.swift
//  Menu_FYP
//
//  Created by Amir Mughal on 11/11/2018.
//  Copyright © 2018 Bilal Shahid. All rights reserved.
//

import UIKit

class LessonsViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let reuseIdentifier = "LessonsCell"
    @IBOutlet weak var Sublessons: UICollectionView!
    @IBOutlet weak var Practice: UIButton!
    var student: User?
    var QaidaData = Qaida()
    var activities = [String]()
    var activityIndex: Int = -1
    override func viewDidLoad() {
        super.viewDidLoad()

        QaidaData = getQaidaData()
        activities = QaidaData.getActivities()
        self.title = activities[activityIndex]
        self.makeBorder(button: Practice)
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9242517352, green: 0.9300937653, blue: 0.9034610391, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        setup()
        
    }
    func setup() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 60, height: 60)
        
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        Sublessons!.collectionViewLayout = layout
        Sublessons?.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! lessonsCell
        cell.subLessonCell.setTitle("Sub Lesson " + String(indexPath.row+1), for: .normal)
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize, height: collectionViewSize/4)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "wordGrid") as! GridViewController
        destinationVC.subLessonIndex=indexPath.row+1
        destinationVC.gridType="subLesson"
        destinationVC.activityIndex=activityIndex
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    @IBAction func PracticeBtn(_ sender: Any) {
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "wordGrid") as! GridViewController
        destinationVC.gridType="practice"
        destinationVC.activityIndex=activityIndex
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func makeBorder(button: UIButton)
    {
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }

}
