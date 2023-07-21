import Combine
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
    public var asyncAuthorize: (UNAuthorizationOptions) async throws -> Bool
    public var schedule: (UNNotificationRequest, @escaping (Error?) -> Void) -> Void
    public var asyncSchedule: (UNNotificationRequest) async throws -> Void
    public var cancelRequests: () -> Void
    public var delegate: AnyPublisher<DelegateEvent, Never>

    public init(
        authorizationStatus: @escaping () -> AuthorizationStatus,
        authorize: @escaping (UNAuthorizationOptions, @escaping (Bool) -> Void) -> Void,
        asyncAuthorize: @escaping (UNAuthorizationOptions) async throws -> Bool,
        schedule: @escaping (UNNotificationRequest, @escaping (Error?) -> Void) -> Void,
        asyncSchedule: @escaping (UNNotificationRequest) async throws -> Void,
        cancelRequests: @escaping () -> Void,
        delegate: AnyPublisher<DelegateEvent, Never>
    ) {
        self.authorizationStatus = authorizationStatus
        self.authorize = authorize
        self.asyncAuthorize = asyncAuthorize
        self.schedule = schedule
        self.asyncSchedule = asyncSchedule
        self.cancelRequests = cancelRequests
        self.delegate = delegate
    }
}

extension NotificationsClient {
    public func authorize(options: UNAuthorizationOptions) async throws -> Bool {
        try await asyncAuthorize(options)
    }
    
    public func authorize(options: UNAuthorizationOptions, then completion: @escaping (Bool) -> Void) {
        authorize(options, completion)
    }

    public func schedule(request: UNNotificationRequest) async throws {
        try await asyncSchedule(request)
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
