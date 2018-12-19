//
//  AudioHashing.swift
//  Soundapp
//
//  Created by Ryan Tiong on 5/10/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

public class AudioHashing {
    var ANCHOR_DISTANCE = 5
    var TARGET_ZONE_SIZE = 5
    
    func hash(peak:Array<[Int]>) ->Array<Fingerprint> {
        var fingerprints = Array<Fingerprint>()
        var candidateAnchors = Array<Int>()
        
        if(peak.count == 0) {
            return fingerprints
        }
        var currentAbsoluteTime = peak.firstIndex(of: [0])
        var tempCandidateIndex = 0
        var tempMaxAmp = 0
        for i in 0...(peak.count - ANCHOR_DISTANCE + TARGET_ZONE_SIZE) {
            var anchor = peak[i]
            if(anchor[0] > currentAbsoluteTime!) {
                candidateAnchors.append(tempCandidateIndex)
                currentAbsoluteTime = anchor[0]
                tempMaxAmp = 0
            }
            if(anchor[2] > tempMaxAmp) {
                tempCandidateIndex = i
                tempMaxAmp = anchor[2]
            }
        }
        
        for i in candidateAnchors {
            for j in (i+ANCHOR_DISTANCE)..<(i+ANCHOR_DISTANCE+TARGET_ZONE_SIZE) {
                var anchor = peak[i]
                var point = peak[j]
                var delta = point[0] - anchor[0]
                fingerprints.insert(anchor[1], point[1], delta, anchor[0], 0)
            }
        }
        
        return fingerprints
    }
}
