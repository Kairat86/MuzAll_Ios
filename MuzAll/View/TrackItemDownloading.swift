import Foundation
import UIKit

class TrackItemDownloading: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    var endAngle = -CGFloat.pi/2
    let sh = CAShapeLayer()
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        let cp=UIBezierPath(arcCenter: CGPoint(x: bounds.size.width/2,y: bounds.size.height/2), radius: bounds.size.width/3, startAngle: -CGFloat.pi/2, endAngle: endAngle, clockwise: true)
//        sh.path=cp.cgPath
//        sh.strokeColor=UIColor.orange.cgColor
//        sh.lineWidth=7
//        sh.lineCap = .round
//        layer.addSublayer(sh)
//    }
    
    func animate(progress:Float) {
        print("animate=>\(progress)")
//        let full = 2*CGFloat.pi
//        let anime=CABasicAnimation(keyPath: "endAngle")
//        anime.toValue=CGFloat(progress)*full
//        anime.fillMode = .forwards
//        anime.isRemovedOnCompletion=false
//        sh.add(anime, forKey: "KEY")
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
