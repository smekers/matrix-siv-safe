//
//  AppView.swift
//  MatrixSiv
//
//  Created by Rachel Castor on 8/13/24.
//

import SwiftUI
import MatrixRustSDK

struct AppView: View {
    @State var client: Client?
    var body: some View {
        if let client {
            Home(viewModel: HomeViewModel(client: client))
        } else {
            Text("Logging In")
                .task {
                    do {
                        client = try await login()
                    } catch {
                        print("Error logging in: \(error)")
                    }
                }
                
        }
    }
    
    func login() async throws -> Client? {
        /// get uniqueish date string
        let dateStr = Date.now.description
        print("building client")
        let client = try await ClientBuilder()
            .sessionPath(path: URL.applicationSupportDirectory.path() + dateStr)
            .serverNameOrHomeserverUrl(serverNameOrUrl: "matrix.org")
            .build()
        
        
        // Login through the service which creates a client.
        print("logging in")
        let username = ProcessInfo.processInfo.environment["MUSERNAME"]
        let password = ProcessInfo.processInfo.environment["MPASSWORD"]
        guard let username, let password else {
            fatalError("Username or password is not set in the env variables")
        }
        try await client.login(username: username, password: password, initialDeviceName: nil, deviceId: nil)
        return client
    }
}

#Preview {
    AppView()
}
