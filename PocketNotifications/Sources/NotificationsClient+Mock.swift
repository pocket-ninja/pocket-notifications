import UserNotifications
import Combine

extension NotificationsClient {
    public static let authorized: NotificationsClient = {
        let publisher = PassthroughSubject<DelegateEvent, Never>()
        
        return NotificationsClient(
            authorizationStatus: { .authorized },
            authorize: { _, completion in
                publisher.send(.didChangeAuthorization(granted: true))
                completion(true)
            },
            asyncAuthorize: { _ in
                publisher.send(.didChangeAuthorization(granted: true))
                return true
            },
            schedule: { _, completion in completion(nil) },
            asyncSchedule: { _ in },
            cancelRequests: {},
            delegate: publisher.eraseToAnyPublisher()
        )
    }()
    
    public static let denied: NotificationsClient = {
        let publisher = PassthroughSubject<DelegateEvent, Never>()
        
        return NotificationsClient(
            authorizationStatus: { .denied },
            authorize: { _, completion in
                publisher.send(.didChangeAuthorization(granted: false))
                completion(false)
            },
            asyncAuthorize: { _ in
                publisher.send(.didChangeAuthorization(granted: false))
                return false
            },
            schedule: { _, completion in completion(nil) },
            asyncSchedule: { _ in },
            cancelRequests: {},
            delegate: publisher.eraseToAnyPublisher()
        )
    }()
}
