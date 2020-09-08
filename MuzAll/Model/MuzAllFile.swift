//
//  MuzAllFile.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 9/4/20.
//

import Foundation

class MuzAllFile {
    var inProgress = false
    var progress = 0
    let url:URL?
    
    init(url:URL) {
        self.url=url
    }
    
    init(inProgress:Bool) {
        self.inProgress=inProgress
        self.url=nil
    }
}
