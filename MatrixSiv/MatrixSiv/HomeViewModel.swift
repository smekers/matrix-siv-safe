//
//  HomeViewModel.swift
//  MatrixSiv
//
//  Created by Rachel Castor on 8/13/24.
//

import Foundation
import MatrixRustSDK
import CryptoKit

class HomeViewModel: ClientDelegate, ObservableObject, RoomListServiceStateListener, RoomListEntriesListener, SyncServiceStateObserver {
    
    
    let client: Client
    var rooms: [Room] = []
    var syncService: SyncService?
    var roomListService: RoomListService?
    
    init(client: Client) {
        self.client = client
        
        rooms = client.rooms()
    }
    func setClientDelegate() async throws{
        print("setup")
        _ = client.setDelegate(delegate: self)
        
        syncService = try await client.syncService().finish()
        await syncService?.start()
        roomListService = syncService?.roomListService()
        _ = roomListService?.state(listener: self)
        /// none found
        // let dummyroom = try  roomListService?.room(roomId: "!kekgIjHPobIMtctiEg")
        // print(dummyroom?.displayName())
        let result = syncService?.state(listener: self)
    }
    func onUpdate(state: MatrixRustSDK.SyncServiceState) {
        print("onUpdate(state: MatrixRustSDK.SyncServiceState)")
        print(state)
        print(client.rooms().count)
    }
    func createRoom() async throws {
        print("creating new room")
        _ = try await client.createRoom(request: CreateRoomParameters(name: "siv-test\(client.session().accessToken)", isEncrypted: false, visibility: .private, preset: .privateChat))
    }
    func sendMessage() async throws {
        print("sending first message")
        guard let room = client.rooms().first else {
            print("No rooms")
            return
        }
        rooms = client.rooms()
        
        _ = """
            <body>

                <p>This is a paragraph.</p>
                <p>This is another paragraph.</p>

            </body>
        """
        let html2 = """
            <!DOCTYPE html>
            <html>
                <body>

                    <h2>HTML Images</h2>
                    <p>HTML images are defined with the img tag:</p>

                    <img src="w3schools.jpg" alt="W3Schools.com" width="104" height="142">

                </body>
            </html>
        """
        let htmlMsg = messageEventContentFromHtml(body: "Hello ", htmlBody: html2)
        let markdownMsg = messageEventContentFromMarkdown(md: "Hello wazzup from dummy")
        _ = try await room.timeline().send(msg: htmlMsg)
    }
    func didReceiveAuthError(isSoftLogout: Bool) {
        print("Error authentication")
    }
    
    func didRefreshTokens() {
        print("Tokens refreshed")
    }

    func updateRooms() async throws {
        print("getting roomlist")
        let roomList = try await roomListService?.allRooms()
        let result = roomList?.entries(listener: self)
        result.publisher.sink { completion in
            print("done getting result")
        } receiveValue: { wee in
            print("done")
        }
        rooms = client.rooms()
        print(client.rooms())

        
    }
    func onUpdate(roomEntriesUpdate: [MatrixRustSDK.RoomListEntriesUpdate]) {
        print("roomEntriesUpdate")
        print(roomEntriesUpdate)
        
        for update in roomEntriesUpdate {
            switch update {
            case .append(let values):
                print("appended")
                print(values)
                print(rooms)
                if rooms.count < 2 {
                    Task {
                        try await updateRooms()
                    }
                } else {
                    for room in rooms {
                        print("room name: \(room.id()) \(room.displayName() ?? "none")")
                        Task {
                            let info = try await roomListService?.room(roomId: room.id()).roomInfo()
                            print("room with id: \(room.id()) \(info?.displayName ?? "none")")
                        }
                        
                    }
                }
                
                
            case .reset(let values):
                print("reset")
                print(values)
            default:
                print(self)
            }
        }
        
        
//        Task {
//            let roomList = try await roomListService?.allRooms()
//            let result = roomList?.entries(listener: self)
//            
//            result.publisher.map { output in
//                output.
//            }
//            print(roomList)
//        }
    }
    func onUpdate(state: MatrixRustSDK.RoomListServiceState) {
        print("state: MatrixRustSDK.RoomListServiceState")
        print(state)
    }
    
}
