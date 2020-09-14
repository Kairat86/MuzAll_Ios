//
//  MyMusicController.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 5/5/20.
//

import UIKit
import QuickLookThumbnailing
import AVFoundation

class MyMusicController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DownloadDelegate {
    
    @IBOutlet weak var grid: UICollectionView!
    var files=[MuzAllFile]()
    let qlg=QLThumbnailGenerator()
    let size: CGSize = CGSize(width: 60, height: 90)
    let scale = UIScreen.main.scale
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        files.count/3+1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let r = files.count-section*3
        return r<3 ? r : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
        let i = indexPath.section*3+indexPath.row
        let f = files[i]
        if f.inProgress {
            let item = grid.dequeueReusableCell(withReuseIdentifier: "TrackItemDownloading", for: indexPath) as! TrackItemDownloading
            item.name.text="Downloading..."
            item.animate(progress: f.progress)
            return item
        }
         let item = grid.dequeueReusableCell(withReuseIdentifier: "TrackItem", for: indexPath) as! TrackItem
        var name = f.url!.lastPathComponent
           name.removeLast(4)
           item.name.text=name
        let asset = AVAsset(url: f.url!) as AVAsset
           for metaDataItems in asset.commonMetadata {
               if metaDataItems.commonKey?.rawValue == "artwork" {
                   let imageData = metaDataItems.value as! NSData
                   var image2: UIImage = UIImage(data: imageData as Data)!
                   item.thumb.image = image2
               }
           }
           return item
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let f=files[indexPath.section*3+indexPath.row]
        var name = f.url!.lastPathComponent
        name.removeLast(4)
        let player = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "player") as! PlayController)
        player.selectedTrack=Track(name: name,id: "1",duration: 2,artist_name: "artist",releasedate: "date",audio: String(describing: f.url!))
        player.isDownloadHidden=true
        present(player,animated: false)
    }
    
     func onDataReceived(percent:Float) {
        print("prog=>\(percent)")
        files[0].progress = percent
        let indexPath=IndexPath.init(item: 0, section: 0)
        DispatchQueue.main.async {
            self.grid.reloadItems(at:[indexPath])
             }
       }
    
    func onFinished() {
        print("on finished")
        files=[]
        DispatchQueue.main.async {
            self.viewDidLoad()
            self.grid.reloadData()
         }
      }
    
    override func viewDidLoad() {
        grid.dataSource=self
        grid.delegate=self
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
        let url = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first
        
        let fm = FileManager()
        if(!fm.fileExists(atPath: url!.path )){
            do{
                try fm.createDirectory(at: url! as URL, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("err=>\(error)")
            }
        }
        do{
            let urls = try FileManager().contentsOfDirectory(at: url! as URL, includingPropertiesForKeys: nil)
            for u in urls {
                files.append(MuzAllFile(url:u))
            }
            if DownloadManager.shared.isDownloading{
                files.insert(MuzAllFile(inProgress: true), at: 0)
                DownloadManager.shared.downloadDelegate=self
            }
        }catch{
            print("err=>\(error)")
        }
    }
}
