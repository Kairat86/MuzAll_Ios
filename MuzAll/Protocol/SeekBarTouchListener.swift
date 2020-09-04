//
//  SeekBarTouchListener.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 7/10/20.
//

import Foundation
import CoreMedia
protocol SeekBarDelegate {
    
    func onTouch(x:Int64, total:Int32)
    func setProgress() 
}
