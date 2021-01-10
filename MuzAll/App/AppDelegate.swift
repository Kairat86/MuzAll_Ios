import UIKit
import AVFoundation
import UserNotifications
import GoogleMobileAds

@UIApplicationMain
class MuzAllAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application:UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            print("Failed to set audio session category.")
        }
        return true
    }}
