import RxRelay
import UserNotifications

extension NotificationsClient {
    public static let live: NotificationsClient = {
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
            getAuthorizationStatus: { completion in
                _ = delegate

                center.getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        completion(settings.authorizationStatus)
                    }
                }
            },
            authorize: { options, completion in
                center.requestAuthorization(options: options) { granted, _ in
                    DispatchQueue.main.async {
                        delegate.relay.accept(.didChangeAuthorization(granted))
                        completion(granted)
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
    }()
}
