//
//  AudioMatching.swift
//  Soundapp
//
//  Created by Ryan Tiong on 11/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation
import android.database.Cursor
import android.util.SparseIntArray

public class AudioMatching {
    private static var match:[Int]
    
    public static func match(fingerprints:[Fingerprint], dbHelper:DBHelper) ->[int]{
        var targetZoneMap = [[Int]:[Int]]()
        var timeCoherenceMap:[SparseIntArray] = SparseIntArray[dbHelper.getnumofAds()]
        for i in dbHelper.getNumOfAds(){
            timeCoherenceMap[i] = SparseIntArray()
        }
        for f:Fingerprint in fingerprints{
            var couples:Cursor = dbHelper.getFingerprintCouples(f.getAnchorFrequency(),f.getPointFrequency(),f.getDelta())
            if(couples.moveToFirst()){
                repeat{
                    var id:Int = couples.getInt(couples.getColumnIndex("ad_id"))
                    var absoluteTime:Int = couples.getInt(couples.getColumnIndex("absolute_time"))
                    var delta:Int = f.getAbsoluteTime() - absoluteTime
                    var couple:[Int]
                    couple.insert(id, at: 0)
                    couple.insert(absoluteTime, at: 1)
                    var a:[Int] = targetZoneMap.get(couple)
                    if(a!=NULL){
                        a.insert(delta, at: 0)
                        targetZoneMap.put(couple,a)
                    }
                    else{
                        a = []()
                        a.append(delta)
                        targetZoneMap.put(couple,a)
                    }
                } while (couples.moveToNext())
            }
            couples.close()
        }
        dbHelper.close()
        
        for i in match.count {
            var s:SparseIntArray = timeCoherenceMap[i]
            var currentMaxDeltaCount:Int = 0
            for j in s.count {
                var delta:Int = s.keyAt(j)
                if(s.get(delta)>=currentMaxDeltaCount){
                    currentMaxDeltaCount = s.get(delta)
                }
            }
            match[i] += currentMaxDeltaCount
        }
        
        var maxTemp:Int = 0
        var maximum:Int = -1
        
        for i in match.count {
            if(match[i]>maxTemp){
                maximum = i
                maxTemp = match[i]
            }
        }
        
        var result:[Int]
        if(maximum>=0){
            result = [maximum, match[maximum]]
        }
        else{
            result = TID_NULL
        }
        return result
    }
    
    public static func reset(dbhelper:DBHelper){
        var match:Int = dbHelper.getNumOfAds()
        dbHelper.close()
    }
}
