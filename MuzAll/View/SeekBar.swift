//
//  SeekBar.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 5/11/20.
//

import UIKit
import CoreMedia
class SeekBar: UIProgressView {
    
    var stopped=false
    var paused=false
    var finished=false
    var timeStep=0.015
    var step:Float=0.02
    var progressAtPause:Float=0
    var touchDelegate:SeekBarDelegate?=nil
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
        startIndeterminate()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let loc = touch.location(in: touch.view)
            print("x=>\(loc.x)")
            print("total=>\(bounds.width)")
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
            progressTintColor=UIColor.orange
            startIndeterminate()
            return
        }else if(paused){
            paused=false
            return
        }else if(finished){
            print("finished")
            setProgress(0, animated: false)
            finished=false
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeStep, execute: {
            if (self.progressTintColor==UIColor.orange){
                self.timeStep=1
                self.touchDelegate?.setProgress()
            }else{
                self.setProgress(self.progress+self.step, animated: true)
            }
            self.startIndeterminate()
        })
    }
    
    func stopIndeterminate(duration:Int, stopped:Bool){
        self.stopped=stopped
    }
    
    func pause() {
        paused=true
    }
    
    func finish()  {
        finished=true
    }
}
