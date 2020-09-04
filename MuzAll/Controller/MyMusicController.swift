//
//  MyMusicController.swift
//  MuzAll
//
//  Created by Kairat Doshekenov on 5/5/20.
//

import UIKit
import QuickLookThumbnailing
import AVFoundation

class MyMusicController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var grid: UICollectionView!
    var fileList=[URL]()
    let qlg=QLThumbnailGenerator()
    let size: CGSize = CGSize(width: 60, height: 90)
    let scale = UIScreen.main.scale
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fileList.count<3 ? fileList.count : 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        let path=fileList[indexPath.row]
        var name = path.lastPathComponent
        name.removeLast(4)
        let player = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "player") as! PlayController)
        player.selectedTrack=Track(name: name,id: "1",duration: 2,artist_name: "artist",releasedate: "date",audio: String(describing: path))
        player.isDownloadHidden=true
        present(player,animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = grid.dequeueReusableCell(withReuseIdentifier: "TrackItem", for: indexPath) as! TrackItem
        let url = fileList[indexPath.row]
        var name: String = url.lastPathComponent
        print(name)
        name.removeLast(4)
        item.name.text=name
        let asset = AVAsset(url: url) as AVAsset
        for metaDataItems in asset.commonMetadata {
            if metaDataItems.commonKey?.rawValue == "artwork" {
                let imageData = metaDataItems.value as! NSData
                var image2: UIImage = UIImage(data: imageData as Data)!
                item.thumb.image = image2
            }
        }
        return item
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
            fileList = try FileManager().contentsOfDirectory(at: url! as URL, includingPropertiesForKeys: nil)
            print("files=>\(fileList)")
        }catch{
            print("err=>\(error)")
        }
    }
}
