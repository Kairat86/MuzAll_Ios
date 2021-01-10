import UIKit
import QuickLookThumbnailing
import AVFoundation
import AudioToolbox


class MyMusicController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DownloadDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var grid: UICollectionView!
    var files=[MuzAllFile]()
    let qlg=QLThumbnailGenerator()
    let size: CGSize = CGSize(width: 60, height: 90)
    let scale = UIScreen.main.scale
    var itemToDel:URL? = nil
    let perSection = UIDevice.current.userInterfaceIdiom == .pad ? 7 : 3
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        files.count/perSection+1
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("test")
//        let collectionWidth = collectionView.bounds.width
//        return CGSize(width: collectionWidth/CGFloat(perSection), height: 250)
//
//    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//           return 50
//       }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let w: CGFloat = UIScreen.main.bounds.width
        print("w=>\(w)")
        let spacing: CGFloat = (w-CGFloat(perSection*108))/CGFloat(perSection)
        print("spacing=>\(spacing)")
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let r = files.count-section*perSection
        return r<perSection ? r : perSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
        let i = indexPath.section*perSection+indexPath.row
        let f = files[i]
        if f.inProgress {
            let item = grid.dequeueReusableCell(withReuseIdentifier: "TrackItemDownloading", for: indexPath) as! TrackItemDownloading
            item.name.text="Downloading..."
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
                   let image2: UIImage = UIImage(data: imageData as Data)!
                   item.thumb.image = image2
               }
           }
//        print("iw=>\(item.frame.width)")
           return item
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let f=files[indexPath.section*3+indexPath.row]
        guard var name = f.url?.lastPathComponent else {return}
        navigationItem.rightBarButtonItem=nil
        name.removeLast(4)
        let player = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "player") as! PlayController)
        player.selectedTrack=Track(name: name,id: "1",duration: 2,artist_name: "artist",releasedate: "date",audio: String(describing: f.url!))
        player.isDownloadHidden=true
        present(player,animated: false)
    }
    
     func onDataReceived(percent:Float) {
        files[0].progress = percent
        let indexPath=IndexPath.init(item: 0, section: 0)

        DispatchQueue.main.async {
            let cell = self.grid.cellForItem(at: indexPath) as! TrackItemDownloading
            cell.animate(progress: percent)
             }
       }
    
    func onFinished(path:URL) {
        print("on finished")
        files[0]=MuzAllFile(url: path)
        DispatchQueue.main.async {
            self.grid.reloadItems(at: [IndexPath.init(item: 0, section: 0)])
         }
      }
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        grid?.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }

        let p = gestureRecognizer.location(in: grid)

        if let indexPath = grid?.indexPathForItem(at: p) {
            print("Long press at item: \(indexPath.row), section: \(indexPath.section)")
            itemToDel = files[indexPath.section*perSection+indexPath.row].url
            navigationItem.rightBarButtonItem=UIBarButtonItem(image: UIImage(systemName: "bin.xmark"), style: .plain, target: self, action: #selector(deleteItem))
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @objc func deleteItem(){
        navigationItem.rightBarButtonItem=nil
        do{
        try FileManager.default.removeItem(at: itemToDel!)
            files.removeAll()
            viewDidLoad()
            grid.reloadData()
        print("deleted \(itemToDel?.lastPathComponent)")
        }catch{
            print("err")
        }
    }
    
    override func viewDidLoad() {
        grid.dataSource=self
        grid.delegate=self
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
        setupLongGestureRecognizerOnCollection()
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
