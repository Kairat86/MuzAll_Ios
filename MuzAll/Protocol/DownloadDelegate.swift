//
//  DownloadDelegate.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 9/4/20.
//

import Foundation

protocol DownloadDelegate {
    
    func onDataReceived(percent:Float)
    
    func onFinished()
}
