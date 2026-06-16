import UIKit
import Flutter

/**
 * Application delegate — configures Flutter engine and registers
 * native platform channel handlers for battery and location.
 */
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private var batteryChannelHandler: BatteryChannelHandler?
    private var batteryEventHandler: BatteryEventHandler?
    private var locationManager: LocationTrackingManager?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        let messenger = controller.binaryMessenger

        // Battery channels
        batteryChannelHandler = BatteryChannelHandler(messenger: messenger)
        batteryEventHandler   = BatteryEventHandler(messenger: messenger)

        // Location manager (background tracking)
        locationManager = LocationTrackingManager.shared

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
