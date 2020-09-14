import Foundation

class DownloadManager: NSObject, URLSessionDownloadDelegate {
    
    static let shared=DownloadManager()
    var downloadDelegate:DownloadDelegate?=nil
    var isDownloading=false
    
    private lazy var urlSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }()
    private var name:String?
    private override init(){}
    
    func download(url:URL, trackName:String?)  {
        name=trackName
        let request = try! URLRequest(url: url)
        let task = urlSession.downloadTask(with: request)
        task.resume()
        isDownloading=true
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
           print("loc=>\(location.absoluteURL)")
           do {
               var path = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.musicDirectory, .userDomainMask, true)[0])
            try FileManager.default.copyItem(at: location, to: path.appendingPathComponent(name!+".mp3")!)
            isDownloading=false
            downloadDelegate?.onFinished()
               print("copy finished")
           } catch (let writeError) {
               print("error writing file: \(writeError)")
           }
       }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("totalBytesWritten=>\(totalBytesWritten) of=>\(totalBytesExpectedToWrite)")
        downloadDelegate?.onDataReceived(percent: Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))
    }
}
