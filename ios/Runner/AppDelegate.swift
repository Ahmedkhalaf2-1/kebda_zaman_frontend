import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // TODO(mac-setup): replace with the real iOS Google Maps API key (see
    // IOS_MAC_HANDOFF.md). Android obtains its key from local.properties at
    // build time; iOS has no equivalent mechanism, so this must be filled in
    // manually before Archive — map screens will fail to render without it.
    GMSServices.provideAPIKey("AIzaSyB3UneS6SICnGQ6jd_uIfIexyKIsxF1acs")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
