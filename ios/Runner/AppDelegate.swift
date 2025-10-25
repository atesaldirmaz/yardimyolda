import UIKit
import Flutter
import UserNotifications

// ⚠️ PLACEHOLDER CONFIGURATION - UPDATE FOR PRODUCTION ⚠️
// Note: Firebase is initialized in Flutter code (main.dart)
// This AppDelegate handles notification permissions and delegates

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Request notification permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle device token registration
  override func application(_ application: UIApplication, 
                           didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ iOS device token registered")
  }
  
  // Handle device token registration failure
  override func application(_ application: UIApplication, 
                           didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ iOS device token registration failed: \(error)")
  }
  
  // Handle foreground notifications
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
  
  // Handle notification tap
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
    print("📬 Notification tapped: \(response.notification.request.content.userInfo)")
    completionHandler()
  }
}
