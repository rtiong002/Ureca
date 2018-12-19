//
//  AudioAnalysis.swift
//  Soundapp
//
//  Created by Ryan Tiong on 22/10/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation


public class AudioAnalysis {
    private static var CHUNK_SIZE:Int = 1024
    private static var RANGE:[Int] = [7,10,20,40,80,512]
    private static var ULTRASOUND_RANGE:[Int] = [465,471,477,483,512]
    private static var FILTER_WINDOW_SIZE:Int = 40
    private static var ABS_MIN_AMP:Int = 4000
    
    public static func analyz(audio:[Int32], mode:String) -> Array<[Int]>{
        var spectrum:[[Complex]] = fft(audio:[Int32])
        return findPeak(spectrum,mode)
    }
    
    private static func fft(audio:[Int32]) -> [[Complex]]{
        var totalSize = audio.count
        var amountPossible = totalSize / CHUNK_SIZE
        var results:[[Complex]] = Complex[amountPossible][]
        for times in amountPossible{
            var complexTemp:[Complex] = Complex[CHUNK_SIZE]
            for i in CHUNK_SIZE{
                complexTemp[i] = Complex(audio[(times * CHUNK_SIZE)+i],0)
            }
            var complex:[Complex] = hammingWindow(complexTemp)
            var fft:FastFourierTransformer = FastFourierTransformer(DftNormalization.UNITARY)
            results[times] = fft.transform(complex, TransformType.FORWARD)
        }
        return results
    }
    
    private static func findPeak(spectrum:[[Complex]]) -> [int]{
        var peak:[[Int]] = [spectrum.count][RANGE.count]
        var highscores:[[Double]] = [spectrum.count][RANGE.count]
        
        var band:Int = 0
        //for every line of data
        for i in spectrum.count{
            for freq in <=(CHUNK_SIZE/2){ //freq starts from 1 thus below states freq+1
                //get the magnitude
                var mag:Double = abs(spectrum[i][freq+1])
                //update band if needed
                if(freq>RANGE[band]){
                    band++
                }
                //save highest magnitude and corresponding frequency
                if(mag>highscores[i][band]){
                    highscores[i][band] = mag
                    peak[i][band] = freq
                }
            }
        }
        var peakFiltered:[int]
        
        var totalMag:[Double] = [((peak.count-1)/FILTER_WINDOW_SIZE)+1]
        var meanMag:[Double] = [((peak.count-1)/FILTER_WINDOW_SIZE)+1]
        var index:Int = 0
        var restCount:Int = 0
        
        while((index+1)*FILTER_WINDOW_SIZE <= peak.count){
            var j=index*FILTER_WINDOW_SIZE
            for j in (index+1)*FILTER_WINDOW_SIZE{
                for k in peak[j].count{
                    totalMag[index] += abs(spectrum[i][peak[j][k]])
                }
            }
            index++
        }
        
        var i=index*FILTER_WINDOW_SIZE
        for i in peak.count{
            for m in peak[i].count{
                totalMag[index] += abs(spectrum[i][peak[i][m]])
                restCount++
            }
        }
        for n in (meanMag.count - 1){
            meanMag[n] = totalMag[n]/(FILTER_WINDOW_SIZE*peak[0].count)
        }
        meanMag[meanMag.count - 1] = totalMag[totalMag.count-1]/restCount
        for k in peak.count{
            for p in peak[k].count{
                var freq:Int = peak[k][p]
                var amp:Double = abs(spectrum[i][freq])
                if(peak[k][p] != 0 && amp >= MeanMag[k/FILTER_WINDOW_SIZE]){
                    var temp:[Int] = [i,freq,amp]
                    peakFiltered.insert(temp, at:peakFiltered.count)
                }
            }
        }
        return peakFiltered
    }
    
    private static func hammingWindow(recordedData:[Complex]) -> [Complex]{
        for n in recordedData.count{
            recordedData[n] = Complex(recordedData[n].getReal()*(0.5-(0.5*Math.cos((2*Math.PI*n)/(recordedData.count-1)))))
        }
        return recordedData
    }
}
