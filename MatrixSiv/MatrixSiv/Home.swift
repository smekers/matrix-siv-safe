//
//  Home.swift
//  MatrixSiv
//
//  Created by Rachel Castor on 8/9/24.
//

import SwiftUI
import MatrixRustSDK

struct Home: View {
    @State var clientName: String? = nil
    @StateObject var viewModel: HomeViewModel
    var body: some View {
        VStack {
            Text("Hello, \(clientName == nil ? "World" : clientName ?? "")!" )
                .task {
                    do {
                        try await viewModel.setClientDelegate()
                        
                        try await viewModel.updateRooms()
                        //                    try await viewModel.createRoom()
                        //                    try await viewModel.sendMessage()
//                        try await Task.sleep(for: .seconds(60))
//                        try await viewModel.updateRooms()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            Button("refresh rooms") {
                Task {
                    do {
                        try await viewModel.updateRooms()
                    } catch {
                        print("Error updating rooms")
                    }
                }
            }
            Text("rooms: \(viewModel.rooms.count)")
//            roomListView
//                .frame(maxWidth: .infinity)
        }
        
        
    }
    
    @ViewBuilder
    var roomListView: some View {
        ForEach(viewModel.rooms, id: \.id) { room in
            HStack {
                Image(systemName: "shared.with.you.circle")
                    size(30)
                Text(room.id())
            }
        }
    }
}

extension View {
    func size(_ size: CGFloat) -> some View {
        return self.frame(width: size, height: size)
    }
}
extension Room: Hashable, Identifiable {
    var identifier: String {
        self.id()
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    public static func == (lhs: MatrixRustSDK.Room, rhs: MatrixRustSDK.Room) -> Bool {
        lhs.id() == rhs.id()
    }
}
