import UserNotifications
import RxRelay

extension NotificationsClient {
    public static let authorized: NotificationsClient = {
        let publisher = PublishRelay<DelegateEvent>()
        
        return NotificationsClient(
            authorizationStatus: { .authorized },
            authorize: { _, completion in
                publisher.accept(.didChangeAuthorization(granted: true))
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
            authorizationStatus: { .denied },
            authorize: { _, completion in
                publisher.accept(.didChangeAuthorization(granted: false))
                completion(false)
            },
            schedule: { _, completion in completion(nil) },
            cancelRequests: {},
            delegate: publisher.asObservable()
        )
    }()
}
