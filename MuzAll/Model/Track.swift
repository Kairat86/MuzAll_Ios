//
//  Track.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 1/19/20.
//  Copyright © 2020 ZigZak. All rights reserved.
//

import Foundation

class Track :Identifiable, Decodable, CustomStringConvertible{
    let name:String
    let duration:Int
    let artist_name:String
    let releasedate:String
    let audio:String
    let image:String
    let id: String
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return Int(lhs.id)==Int(rhs.id)
    }
    
    
    init(name:String, id:String, duration:Int, artist_name:String, releasedate:String, audio:String, image:String="") {
        self.name=name
        self.id=id
        self.duration=duration
        self.artist_name=artist_name
        self.releasedate=releasedate
        self.audio=audio
        self.image=image
    }
    
    public var description: String { return "\(name)" }
    
}
