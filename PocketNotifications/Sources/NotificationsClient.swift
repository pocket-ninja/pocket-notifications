import RxSwift
import UserNotifications

public struct NotificationsClient {
    public enum AuthorizationStatus: String, Equatable, Codable {
        case notDetermined
        case denied
        case authorized
    }

    public enum DelegateEvent {
        case didChangeAuthorization(granted: Bool)
        case willPresent(notification: UNNotification, completion: (UNNotificationPresentationOptions) -> Void)
        case didReceive(response: UNNotificationResponse, completionHandler: () -> Void)
        case openSettings(notification: UNNotification?)
    }

    public var authorizationStatus: () -> AuthorizationStatus
    public var authorize: (UNAuthorizationOptions, @escaping (Bool) -> Void) -> Void
    public var schedule: (UNNotificationRequest, @escaping (Error?) -> Void) -> Void
    public var cancelRequests: () -> Void
    public var delegate: Observable<DelegateEvent>

    public init(
        authorizationStatus: @escaping () -> AuthorizationStatus,
        authorize: @escaping (UNAuthorizationOptions, @escaping (Bool) -> Void) -> Void,
        schedule: @escaping (UNNotificationRequest, @escaping (Error?) -> Void) -> Void,
        cancelRequests: @escaping () -> Void,
        delegate: Observable<DelegateEvent>
    ) {
        self.authorizationStatus = authorizationStatus
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

extension NotificationsClient.AuthorizationStatus {
    public var canSendNotifications: Bool {
        switch self {
        case .authorized: return true
        case .denied, .notDetermined: return false
        }
    }

    public static func from(_ status: UNAuthorizationStatus) -> Self {
        switch status {
        case .authorized: return .authorized
        case .notDetermined: return .notDetermined
        default: return .denied
        }
    }
}
