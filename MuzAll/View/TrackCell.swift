//
//  TrackCell.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 3/27/20.
//

import Foundation
import UIKit

class TrackCell: UITableViewCell {
    
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var artisName: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lic: UILabel!
    var licence=""
    
    @IBAction func lic(_ sender: UIButton) {
        open(scheme: licence)
    }
    
    func open(scheme: String) {
       if let url = URL(string: scheme) {
          if #available(iOS 10, *) {
             UIApplication.shared.open(url, options: [:],
               completionHandler: {
                   (success) in
                      print("Open \(scheme): \(success)")
               })
         } else {
             let success = UIApplication.shared.openURL(url)
             print("Open \(scheme): \(success)")
         }
       }
     }
}
