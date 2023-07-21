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
            schedule: { _, completion in completion(nil) },
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
            schedule: { _, completion in completion(nil) },
            cancelRequests: {},
            delegate: publisher.eraseToAnyPublisher()
        )
    }()
}
