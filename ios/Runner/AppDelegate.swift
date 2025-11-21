import Flutter
import UIKit
import FBSDKCoreKit
import GoogleSignIn

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Initialize Facebook SDK
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    
    // Initialize Google Sign-In
    // Get the CLIENT_ID from GoogleService-Info.plist
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
       let plist = NSDictionary(contentsOfFile: path),
       let clientId = plist["CLIENT_ID"] as? String {
      // Configure Google Sign-In
      let configuration = GIDConfiguration(clientID: clientId)
      GIDSignIn.sharedInstance.configuration = configuration
    } else {
      print("Warning: Could not find CLIENT_ID in GoogleService-Info.plist")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle URL callbacks for Facebook, Google Sign-In, and Firebase
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle Facebook URL
    if ApplicationDelegate.shared.application(app, open: url, options: options) {
      return true
    }
    
    // Handle Google Sign-In URL
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    // Handle Firebase Auth URL (for OAuth redirects)
    if url.scheme == "https" && url.host == "eassac-72d96.firebaseapp.com" {
      return super.application(app, open: url, options: options)
    }
    
    return super.application(app, open: url, options: options)
  }
  
  // Handle URL schemes (for iOS 8 and earlier)
  override func application(
    _ application: UIApplication,
    open url: URL,
    sourceApplication: String?,
    annotation: Any
  ) -> Bool {
    // Handle Facebook URL
    if ApplicationDelegate.shared.application(
      application,
      open: url,
      sourceApplication: sourceApplication,
      annotation: annotation
    ) {
      return true
    }
    
    // Handle Google Sign-In URL
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    
    return super.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
  }
}
