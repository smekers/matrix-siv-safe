//
//  MenuView.swift
//  MatrixSiv
//
//  Created by Rachel Castor on 7/1/25.
//

import SwiftUI
struct MenuView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack (alignment: .leading) {
            header
            Divider()
            content
        }
    }
    
    var content: some View {
        VStack {
            Button {
                Task {
                    await logout()
                }
            } label: {
                Text("Logout")
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    var header: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .squareSize(20)
                    .padding(2)
                    .foregroundStyle(.sivPrimary)
            }
        }
        .padding(.horizontal, 16)
    }
    
    func logout() async {
        await MatrixManager.shared.logout()
    }
}
