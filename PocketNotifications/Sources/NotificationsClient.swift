import RxSwift
import UserNotifications

public struct NotificationsClient {
    public enum DelegateEvent {
        case didChangeAuthorization(Bool)
        case willPresent(notification: UNNotification, completion: (UNNotificationPresentationOptions) -> Void)
        case didReceive(response: UNNotificationResponse, completionHandler: () -> Void)
        case openSettings(notification: UNNotification?)
    }

    public var getAuthorizationStatus: (@escaping (UNAuthorizationStatus) -> Void) -> Void
    public var authorize: (UNAuthorizationOptions, @escaping (Bool) -> Void) -> Void
    public var schedule: (UNNotificationRequest, @escaping (Error?) -> Void) -> Void
    public var cancelRequests: () -> Void
    public var delegate: Observable<DelegateEvent>

    public init(
        getAuthorizationStatus: @escaping (@escaping (UNAuthorizationStatus) -> Void) -> Void,
        authorize: @escaping (UNAuthorizationOptions, @escaping (Bool) -> Void) -> Void,
        schedule: @escaping (UNNotificationRequest, @escaping (Error?) -> Void) -> Void,
        cancelRequests: @escaping () -> Void,
        delegate: Observable<DelegateEvent>
    ) {
        self.getAuthorizationStatus = getAuthorizationStatus
        self.authorize = authorize
        self.schedule = schedule
        self.cancelRequests = cancelRequests
        self.delegate = delegate
    }
}

extension NotificationsClient {
    public func authorize(options: UNAuthorizationOptions, then completion: @escaping (Bool) -> Void) {
        authorize(options, completion)
    }

    public func schedule(request: UNNotificationRequest, then completion: @escaping (Error?) -> Void) {
        schedule(request, completion)
    }
}
