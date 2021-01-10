import UIKit
import CoreMedia
class SeekBar: UIProgressView {
    
    var stopped=false
    var paused=false
    var finished=false
    var timeStep=0.02
    var step:Float=0.03
    var progressAtPause:Float=0
    var touchDelegate:SeekBarDelegate?=nil
    var prgrLayer=CALayer()
    var primaryPrgr :CGRect!

    required init?(coder: NSCoder) {
        super.init(coder:coder)
        prgrLayer.backgroundColor=UIColor.red.cgColor
        progressTintColor=nil
        primaryPrgr = CGRect(origin: .zero, size: CGSize(width: 0, height: frame.height))
        prgrLayer.frame=primaryPrgr
        layer.addSublayer(prgrLayer)
        startIndeterminate()
    }
    
    fileprivate func drawIndeterminateProgress(_ rect: CGRect) {
        let lineWidth = 35
        let w=rect.size.width*CGFloat(progress)
        if w.isLess(than: CGFloat(lineWidth)) {
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.orange.cgColor)
            context?.setLineWidth(rect.height)
            context?.move(to: .zero)
            context?.addLine(to: CGPoint(x:w, y:rect.height))
            context?.strokePath()
        }else{
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.setLineWidth(rect.height)
            context?.move(to:CGPoint(x:w-CGFloat(lineWidth), y:rect.height) )
            context?.addLine(to: CGPoint(x:rect.size.width, y:rect.height))
            context?.strokePath()
        }
       
    }
    
    override func draw(_ rect: CGRect) {
        if prgrLayer.backgroundColor==UIColor.orange.cgColor{
            let context = UIGraphicsGetCurrentContext()
            context?.setStrokeColor(UIColor.orange.cgColor)
            context?.setLineWidth(rect.height)
            context?.move(to: .zero)
            context?.addLine(to: CGPoint(x:rect.size.width*CGFloat(progress), y:rect.height))
            context?.strokePath()
        }else{
            drawIndeterminateProgress(rect)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: touch.view)
            let seekPoint: Float = Float(loc.x/bounds.width)
            setProgress(seekPoint, animated: false)
            touchDelegate?.onTouch(x: Int64(Int(loc.x)), total:Int32(Int(bounds.width)))
        }
    }
    
    func startIndeterminate(){
        if(progress==1.0){
            setProgress(0, animated: false)
        }else if(stopped){
            setProgress(0, animated: false)
            stopped=false
            prgrLayer.backgroundColor=UIColor.orange.cgColor
            startIndeterminate()
            return
        }else if(paused){
            paused=false
            return
        }else if(finished){
            setProgress(0, animated: false)
            finished=false
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeStep, execute: {
            if (self.prgrLayer.backgroundColor==UIColor.orange.cgColor){
                self.timeStep=1
                self.touchDelegate?.setProgress()
            }else{
                self.setProgress(self.progress+self.step, animated: true)
            }
            self.startIndeterminate()
        })
    }
    
    func stopIndeterminate(stopped:Bool){
        self.stopped=stopped
    }
    
    func pause() {
        paused=true
    }
    
    func finish()  {
        finished=true
    }
}
