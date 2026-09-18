//
//  ChatInputView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI

struct ChatInputView: View {
    
    @Binding var message: String
    
    var onSend: () -> Void
    
    @FocusState var isTyping: Bool
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            TextField("Message", text: $message, axis: .vertical)
                .font(AppFont.font(.regular, size: 16))
                .focused($isTyping)
                .lineLimit(1...5)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(Capsule())
            
            Button {
                onSend()
            } label: {
                
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(uiColor: .systemBackground))
                    .frame(width: 46, height: 46)
                    .background(Color.primary)
                    .clipShape(Circle())
            }
            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: message)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(uiColor: .systemBackground))
        .overlay(alignment: .top) {
            Divider()
        }
    }
}
