//
//  AppView2.swift
//  MatrixSiv
//
//  Created by Rachel Castor on 4/25/25.
//

import SwiftUI
import MatrixRustSDK

struct AppView2: View {
    @State var isAuthenticated: Bool = false
    @State var matrixClient: Client? = nil
    @State var isLoading = true
    @State var animateGradient: Bool = false
    var body: some View {
        Group {
            if MatrixManager.shared.isLoggedIn() {
                RoomListView()
            } else {
                AuthView()
            }
        }
        .overlay(content: {
            if isLoading || MatrixManager.shared.roomListLoadingState == .notLoaded {
                Rectangle()
                    .sivGradientMask(startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                    .onAppear {
                            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                                animateGradient.toggle()
                            }
                        }
                    .ignoresSafeArea(.all)
            }
            
        })
        .task  {
            isLoading = true
            if let existingSession = Session.loadFromUserDefaults() {
                print("Session found. attempting to restore")
                
                await MatrixManager.restoreSession(session: existingSession)
                
            }
            isLoading = false
        }
        
        
    }
}

#Preview {
    AppView2()
}
