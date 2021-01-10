import UIKit
import GoogleMobileAds

class TrackTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, GADBannerViewDelegate {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet var table: UITableView!
    var aIC :UIViewController?=nil
    var selectedTrack:Track?=nil
    var appeared=false
    let f=Bundle.main.path(forResource: "local",ofType:"properties") ?? "NULL"
    var tracks = [Track]()
    var popularHolder=[Track]()
    var searching=false
    var currentQuery=""
    var noResults=false
    var v:UISearchBar?=nil
    var bannerView: GADBannerView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        cell.contentView.autoresizesSubviews=true
        let t = tracks[indexPath.row]
        cell.name.text = t.name
        cell.artisName.text=t.artist_name
        cell.artisName.sizeToFit()
        cell.duration.text="Duration: "+String(t.duration)
        cell.releaseDate.text="Released:"+t.releasedate
        guard let url=URL(string: t.image) else{
            preconditionFailure("Failed to construct URL")
        }
        URLSession.shared.dataTask(with:url){data, response, error in
            if let data=data{
                let img=UIImage(data: data)
                DispatchQueue.main.sync {
                    cell.img.image=img
                }
            }
        }.resume()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrack=tracks[indexPath.row]
        
        let player = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "player") as! PlayController)
        
        player.selectedTrack=selectedTrack
        player.isDownloadHidden=true
        present(player,animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row==tracks.count-1 && !noResults  {
            present(aIC!,animated: false)
            if searching{
                searchTracks(offset: tracks.count, query:currentQuery)
            }else{
                loadTracks(tracks.count)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!appeared){
            aIC=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ai")
            present(aIC!,animated: false)
            appeared=true
        }
    }
    
    override func viewDidLoad() {
        table.tableFooterView=UIView()
        loadTracks(0)
        table.dataSource=self
        table.delegate=self
        v = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width*2/3, height: 20))
        navItem.leftBarButtonItems=[UIBarButtonItem(image: UIImage(systemName: "arrow.counterclockwise"), style: .plain, target: self, action:#selector(reset)),UIBarButtonItem(customView: v!)]
        
        navItem.hidesBackButton=false
        v?.delegate=self
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-8761730220693010/7718030736"
        bannerView.rootViewController = self
        bannerView.delegate=self
        bannerView.load(GADRequest())
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
      addBannerViewToView(bannerView)
    }
    
//    test banner id:ca-app-pub-3940256099942544/2934735716
//    banner id: ca-app-pub-8761730220693010/7718030736
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
      bannerView.translatesAutoresizingMaskIntoConstraints = false
        table.translatesAutoresizingMaskIntoConstraints=false
      view.addSubview(bannerView)
      view.addConstraints(
        [NSLayoutConstraint(item: bannerView,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .bottom,
                            multiplier: 1,
                            constant: -9),
         NSLayoutConstraint(item: bannerView,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: table,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: bannerView,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: table,
                            attribute: .top,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .top,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: table,
                            attribute: .leading,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .leading,
                            multiplier: 1,
                            constant: 0),
         NSLayoutConstraint(item: table,
                            attribute: .trailing,
                            relatedBy: .equal,
                            toItem: view,
                            attribute: .trailing,
                            multiplier: 1,
                            constant: 0)
        ])
     }
    @objc func reset() {
        print("reset in search=>\(searching)")
        if !searching {return}
        tracks=popularHolder
        table.reloadData()
        searching=false
    }
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search for: \(searchBar.text)")
        present(aIC!,animated: false)
        if !searching{
            popularHolder=tracks
            tracks=[Track]()
        }else{
            tracks.removeAll()
        }
        noResults=false
        searchTracks(offset: 0, query: searchBar.text!)
        searching=true
    }
    
    func searchTracks(offset:Int, query:String){
        currentQuery=query
        let fileContent = try! NSString(contentsOfFile:f, encoding: String.Encoding.utf8.rawValue)
        let arr = fileContent.components(separatedBy: "\n")
        let host=arr[0]
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.path="/v3.0/tracks"
        components.queryItems=[
            URLQueryItem(name:"format",value:"json"),
            URLQueryItem(name:"limit",value:"25"),
            URLQueryItem(name:"client_id",value:arr[1]),
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "offset", value:String(offset))
        ]
        guard let url=components.url else {
            preconditionFailure("Failed to construct URL")
        }
        URLSession.shared.dataTask(with: url) {
            data, response, error in
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(Response.self, from: data ?? Data())
                if response.results.count==0{
                    self.noResults=true
                    DispatchQueue.main.sync {[weak self]  in
                        self?.dismiss(animated: false)
                    }
                    return
                }
                DispatchQueue.main.sync {[weak self]  in
                    self?.tracks+=response.results
                    self?.table.reloadData()
                    self?.dismiss(animated: false)
                    self?.v?.endEditing(true)
                }
            } catch {
                print("err=>\(error)")
            }
        }.resume()
    }
    
    @objc func showMyMusic(){
        performSegue(withIdentifier: "music", sender: self)
    }
    
     private func loadTracks(_ offset:Int) {
        let fileContent = try! NSString(contentsOfFile:f, encoding: String.Encoding.utf8.rawValue)
        let arr = fileContent.components(separatedBy: "\n")
        let host=arr[0]
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path="/v3.0/tracks"
        components.queryItems=[
            URLQueryItem(name:"format",value:"json"),
            URLQueryItem(name:"limit",value:"25"),
            URLQueryItem(name:"client_id",value:arr[1]),
            URLQueryItem(name: "order", value: "popularity_month"),
            URLQueryItem(name: "offset", value:String(offset))
        ]
        guard let url=components.url else {
            preconditionFailure("Failed to construct URL")
        }
        URLSession.shared.dataTask(with: url) {
            data, response, error in
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(Response.self, from: data ?? Data())
                print("resp=>\(response)")
                DispatchQueue.main.sync {[weak self]  in
                    self?.tracks+=response.results
                    self?.table.reloadData()
                    self?.dismiss(animated: false)
                }
            } catch {
                print("err=>\(error)")
            }
        }.resume()
    }
    
}
