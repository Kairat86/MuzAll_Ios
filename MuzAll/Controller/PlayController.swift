//
//  PlayController.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 4/10/20.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
class PlayController: UIViewController, SeekBarDelegate, ObservableObject {
    
    
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var seekBar: SeekBar!
    @IBOutlet weak var name: UILabel!
    var isDownloadHidden=false
    var selectedTrack:Track?=nil
    var audioPlayer:AVPlayer?=nil
    var stopped=true
    
    
    override func viewDidLoad() {
        name.text=selectedTrack?.name
        play(trackUrl: selectedTrack!.audio)
        seekBar.touchDelegate=self
        if isDownloadHidden {download.removeFromSuperview()}
    }
    
    func onTouch(x: Int64, total:Int32) {
        audioPlayer?.seek(to: CMTimeMake(value: Int64((audioPlayer?.currentItem?.duration.seconds)!)*x,timescale: total))
    }
    
    func setProgress() {
        seekBar.setProgress(Float((audioPlayer?.currentTime().seconds)!/(audioPlayer?.currentItem?.duration.seconds)!), animated: true)
    }
    
    @IBAction func playPause(_ sender: UIButton) {
        if audioPlayer?.timeControlStatus==AVPlayer.TimeControlStatus.playing {
            audioPlayer?.pause()
            sender.setImage(UIImage(systemName: "play.circle"), for: .normal)
            seekBar.pause()
        }else{
            stopped=false
            audioPlayer?.play()
            seekBar.startIndeterminate()
            sender.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        }
    }
    
    @IBAction func download(_ sender: Any) {
        DownloadManager.shared.download(url: URL.init(string: selectedTrack!.audio)!, trackName:selectedTrack?.name)
    }
    
    func play(trackUrl: String) {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = AVPlayer(url: URL.init(string: trackUrl)!)
            let controller = AVPlayerViewController()
            controller.player = audioPlayer
            self.addChild(controller)
            audioPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options:[.old,.new], context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem)
            audioPlayer?.play()
        } catch {
            print(error)
        }
        
    }
    
    @objc func playerDidFinishPlaying(note:NSNotification) {
        btnPlayPause.setImage(UIImage(systemName: "play.circle"), for: .normal)
        seekBar.finish()
        audioPlayer?.seek(to: CMTime.zero)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if audioPlayer?.timeControlStatus == AVPlayer.TimeControlStatus.playing{
            let dur: Double = (audioPlayer?.currentItem?.duration.seconds)!
            seekBar.stopIndeterminate(duration: Int(dur),stopped:stopped)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if view == touches.first?.view{
            seekBar.stopIndeterminate(duration: 0, stopped: true)
            audioPlayer?.pause()
            dismiss(animated: false)
        }
    }
}
