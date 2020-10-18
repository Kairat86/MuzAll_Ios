import Foundation
import UIKit

class TrackItemDownloading: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    var endAngle = -CGFloat.pi/2
    let sh = CAShapeLayer()
    
    func animate(progress:Float) {
        print("animate=>\(progress)")
        sh.removeFromSuperlayer()
        let cp=UIBezierPath(arcCenter: CGPoint(x: bounds.size.width/2,y: bounds.size.height/2*0.8), radius: bounds.size.height/3, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi*CGFloat(2*progress-0.5), clockwise: true)
        sh.path=cp.cgPath
        sh.strokeColor=UIColor.orange.cgColor
        sh.lineWidth=7
        sh.fillColor=UIColor.clear.cgColor
        sh.lineCap = .round
        layer.addSublayer(sh)
    }
}
