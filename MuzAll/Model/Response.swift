//
//  Response.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 2/20/20.
//  Copyright © 2020 ZigZak. All rights reserved.
//

import Foundation

class Response: Decodable {
    let results:[Track]
    
    init(results:[Track]) {
        self.results=results
    }
}
