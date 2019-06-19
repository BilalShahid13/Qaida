//
//  QaidaDatatoArray.swift
//  Alif_Laam_Meem
//
//  Created by Amir Mughal on 18/11/2018.
//  Copyright © 2018 Bilal Shahid. All rights reserved.
//

import Foundation

func getQaidaData()->Qaida{
    let QaidaData = Qaida()
    print("Hello")
    if let levelURL = Bundle.main.url(forResource: "activityLevels", withExtension: "plist") {
        print("Hello")
        if let Levels = NSArray(contentsOf: levelURL) as? [String] {
            for i in 0..<Levels.count{
                if let activityURL = Bundle.main.url(forResource: String(i), withExtension: "plist") {
                    if let activit = NSArray(contentsOf: activityURL) as? [String] {
                        let a = activity(name: Levels[i],words: activit)
                        QaidaData.addActivity(level: a)
                    }
                    
                }
            }
        }
    }
    return QaidaData
}
