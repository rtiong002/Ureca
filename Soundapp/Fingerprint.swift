//
//  Fingerprint.swift
//  Soundapp
//
//  Created by Ryan Tiong on 5/10/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

public class Fingerprint {
    var anchorFrequency :u_short
    var pointFrequency :u_short
    var delta :UInt8
    var absoluteTime :u_short
    var adID :Int
    
    init(anchorFrequency :u_short, pointFrequency :u_short, delta :UInt8, absoluteTime :u_short, adID :Int){
        self.anchorFrequency = anchorFrequency
        self.pointFrequency = pointFrequency
        self.delta = delta
        self.absoluteTime = absoluteTime
        self.adID = adID
    }
    
    func getAnchorFrequency() -> u_short {
        return anchorFrequency
    }
    
    func getPointFrequency() -> u_short {
        return pointFrequency
    }
    
    func getDelta() -> UInt8 {
        return delta
    }
    
    func getAbsoluteTime() -> u_short {
        return absoluteTime
    }
    
    func getAdID() -> Int {
        return adID
    }
}
