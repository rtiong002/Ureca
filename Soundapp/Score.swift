//
//  Score.swift
//  Soundapp
//
//  Created by Ryan Tiong on 22/10/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

public class Score{
    private var adID:Int
    private var score:Int
    init (adID:Int, score:Int){
        self.adID = adID
        self.score = score
    }
    func getAdID() -> Int {
        return adID
    }
    func getScore() -> Int {
        return score
    }
}
