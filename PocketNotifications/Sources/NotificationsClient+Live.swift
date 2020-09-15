import RxRelay
import UserNotifications

extension NotificationsClient {
    public static func live(defaults: UserDefaults = .standard) -> NotificationsClient {
        class Delegate: NSObject, UNUserNotificationCenterDelegate {
            var relay = PublishRelay<DelegateEvent>()

            func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
                relay.accept(.openSettings(notification: notification))
            }

            func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                relay.accept(.didReceive(response: response, completionHandler: completionHandler))
            }

            func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
                relay.accept(.willPresent(notification: notification, completion: completionHandler))
            }
        }

        let center = UNUserNotificationCenter.current()
        let delegate = Delegate()
        center.delegate = delegate

        return NotificationsClient(
            authorizationStatus: { defaults.authorizationStatus ?? .notDetermined },
            authorize: { options, completion in
                center.requestAuthorization(options: options) { granted, _ in
                    DispatchQueue.main.async {
                        delegate.relay.accept(.didChangeAuthorization(granted: granted))
                        completion(granted)
                        defaults.authorizationStatus = granted ? .authorized : .denied
                    }
                }
                UIApplication.shared.registerForRemoteNotifications()
            },
            schedule: { request, completion in
                center.add(request) { error in
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            },
            cancelRequests: {
                center.removeAllDeliveredNotifications()
                center.removeAllPendingNotificationRequests()
            },
            delegate: delegate.relay.asObservable()
        )
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
