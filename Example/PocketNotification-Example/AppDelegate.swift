import UIKit
import PocketNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let client = NotificationsClient.live()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("Remote Notifications status: \(client.authorizationStatus())")
        
        client.authorize(options: [.sound, .badge, .alert]) { granted in
            print("Remote Notifications authorized: \(granted)")
        }
    
        return true
    }
}
