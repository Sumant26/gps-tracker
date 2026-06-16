import Flutter
import UIKit

private let kEventChannelName = "battery_event_channel"

/**
 * Streams real-time battery level changes to Flutter via `EventChannel`.
 *
 * Observes `UIDevice.batteryLevelDidChangeNotification` using
 * `UIDevice` battery APIs — no third-party packages are used.
 */
class BatteryEventHandler: NSObject, FlutterStreamHandler {

    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    private var observer: NSObjectProtocol?

    init(messenger: FlutterBinaryMessenger) {
        eventChannel = FlutterEventChannel(name: kEventChannelName, binaryMessenger: messenger)
        super.init()
        eventChannel.setStreamHandler(self)
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.sendBatteryLevel()
        }
        // Emit initial value immediately.
        sendBatteryLevel()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        eventSink = nil
        return nil
    }

    // MARK: - Private

    private func sendBatteryLevel() {
        let level = UIDevice.current.batteryLevel
        guard level >= 0 else { return }
        eventSink?(Int(level * 100))
    }
}
