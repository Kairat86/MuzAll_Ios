import UIKit
import AVFoundation
import UserNotifications

@UIApplicationMain
class MuzAllAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application:UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("app")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            print("Failed to set audio session category.")
        }
        return true
    }
    
//    func registerForPushNotifications() {
//            UNUserNotificationCenter.current()
//                .requestAuthorization(options: [.alert, .sound, .badge]) {(granted, error) in
//                    print("Permission granted: \(granted)")
//            }
//    }

    
}
