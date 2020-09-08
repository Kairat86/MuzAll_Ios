import Foundation
import UIKit

class TrackItemDownloading: UICollectionViewCell {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
               let sh = CAShapeLayer()
        let cp=UIBezierPath(arcCenter: CGPoint(x: frame.midX,y: frame.midY), radius: frame.size.width, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
               sh.path=cp.cgPath
               sh.strokeColor=UIColor.orange.cgColor
               sh.lineWidth=10
               layer.addSublayer(sh)
    }
}
