//
//  Created by sroik on 30.01.26.
//

import SwiftUI
import PocketNotifications
import UserNotifications

struct ContentView: View {
    @State private var status: NotificationsClient.AuthorizationStatus = .notDetermined
    private var client = NotificationsClient.live()
    
    var body: some View {
        VStack(spacing: 50) {
            Group {
                switch status {
                case .notDetermined:
                    Text("Not Determined")
                case .authorized:
                    Text("Authorized")
                case .denied:
                    Text("Denied")
                }
            }
            .font(.system(size: 22, weight: .bold))
            
            Button(action: {
                Task {
                    await client.authorize(options: [.alert, .badge, .sound])
                }
            }, label: {
                Text("Authorize")
            })
            .buttonStyle(.glassProminent)
        }
        .onReceive(client.delegate) { event in
            switch event {
            case .didChangeAuthorization(let status):
                self.status = status
            default:
                break
            }
        }
        .task {
            status = client.authorizationStatus()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
