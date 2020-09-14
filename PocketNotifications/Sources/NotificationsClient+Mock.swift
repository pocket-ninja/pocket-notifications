import UserNotifications
import RxRelay

extension NotificationsClient {
    public static let authorized: NotificationsClient = {
        let publisher = PublishRelay<DelegateEvent>()
        
        return NotificationsClient(
            getAuthorizationStatus: { $0(.authorized) },
            authorize: { _, completion in
                publisher.accept(.didChangeAuthorization(true))
                completion(true)
            },
            schedule: { _, completion in completion(nil) },
            cancelRequests: {},
            delegate: publisher.asObservable()
        )
    }()
    
    public static let denied: NotificationsClient = {
        let publisher = PublishRelay<DelegateEvent>()
        
        return NotificationsClient(
            getAuthorizationStatus: { $0(.denied) },
            authorize: { _, completion in
                publisher.accept(.didChangeAuthorization(false))
                completion(false)
            },
            schedule: { _, completion in completion(nil) },
            cancelRequests: {},
            delegate: publisher.asObservable()
        )
    }()
}
