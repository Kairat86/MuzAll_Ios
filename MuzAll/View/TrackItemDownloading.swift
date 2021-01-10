import Foundation
import UIKit

class TrackItemDownloading: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var progressLbl: UILabel!
    var endAngle = -CGFloat.pi/2
    let sh = CAShapeLayer()
    var currProg=0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sh.strokeColor=UIColor.orange.cgColor
        sh.fillColor=UIColor.clear.cgColor
        sh.lineWidth=7
        sh.lineCap = .round
        layer.addSublayer(sh)
    }
    
    func animate(progress:Float) {
        currProg=Int(progress*100)
        let cp=UIBezierPath(arcCenter: CGPoint(x: bounds.size.width/2,y: bounds.size.height/2*0.8), radius: bounds.size.height/3, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi*CGFloat(2*progress-0.5), clockwise: true)
        sh.path=cp.cgPath
        progressLbl.text = String(currProg)+"%"    }
}
