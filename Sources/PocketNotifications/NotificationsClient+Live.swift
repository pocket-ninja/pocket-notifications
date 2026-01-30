import Combine
import UIKit
import UserNotifications

extension NotificationsClient {
    public static func live(defaults: UserDefaults = .standard) -> NotificationsClient {
        let liveClient = LiveClient()
        liveClient.defaults = defaults
        liveClient.setup()

        return NotificationsClient(
            authorizationStatus: { liveClient.status },
            authorize: liveClient.authorize(options:then:),
            schedule: liveClient.schedule(request:then:),
            cancelRequests: liveClient.cancelRequests,
            delegate: liveClient.publisher.eraseToAnyPublisher()
        )
    }
}

extension NotificationsClient {
    final class LiveClient: NSObject, UNUserNotificationCenterDelegate {
        var publisher = PassthroughSubject<DelegateEvent, Never>()
        var center = UNUserNotificationCenter.current()
        var defaults = UserDefaults.standard
        var didBecomeActiveCancellable: Any?

        var status: AuthorizationStatus {
            get {
                defaults.authorizationStatus ?? .notDetermined
            }

            set {
                guard status != newValue else {
                    return
                }

                defaults.authorizationStatus = newValue
                publisher.send(.didChangeAuthorization(status: newValue))
            }
        }

        func setup() {
            center.delegate = self

            didBecomeActiveCancellable = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: OperationQueue.main,
                using: { [weak self] _ in
                    self?.updateStatus()
                }
            )
        }

        func updateStatus() {
            center.getNotificationSettings { [weak self] settings in
                DispatchQueue.main.async {
                    self?.status = AuthorizationStatus(settings.authorizationStatus)
                }
            }
        }

        func schedule(request: UNNotificationRequest, then completion: @escaping (Error?) -> Void) {
            center.add(request) { error in
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
        
        func authorize(options: UNAuthorizationOptions, then completion: @escaping (Bool) -> Void) {
            center.requestAuthorization(options: options) { [weak self] granted, _ in
                DispatchQueue.main.async {
                    self?.status = granted ? .authorized : .denied
                    completion(granted)
                }
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        func cancelRequests() {
            center.removeAllDeliveredNotifications()
            center.removeAllPendingNotificationRequests()
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
            publisher.send(.openSettings(notification: notification))
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            publisher.send(.didReceive(response: response, completionHandler: completionHandler))
        }

        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            publisher.send(.willPresent(notification: notification, completion: completionHandler))
        }
    }
}

private extension UserDefaults {
    var authorizationStatus: NotificationsClient.AuthorizationStatus? {
        get {
            string(forKey: .authorizationStatusKey)
                .flatMap(NotificationsClient.AuthorizationStatus.init(rawValue:))
        }
        set {
            if let value = newValue {
                set(value.rawValue, forKey: .authorizationStatusKey)
            } else {
                removeObject(forKey: .authorizationStatusKey)
            }
        }
    }
}

private extension String {
    static let authorizationStatusKey = "com.pocket-ninja.notifications.authorizationStatus"
}
