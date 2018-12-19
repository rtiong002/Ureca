//
//  Advertisement.swift
//  Soundapp
//
//  Created by Ryan Tiong on 13/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

public class Advertisement {
    var name:String
    var details:String
    var link:String
    var imageID:Int
    var adID:Int
    
    init (name:String, details:String, link:String, imageID:Int, adID:Int){
        self.name = name
        self.details = details
        self.link = link
        self.imageID = imageID
        self.adID = adID
    }
}
