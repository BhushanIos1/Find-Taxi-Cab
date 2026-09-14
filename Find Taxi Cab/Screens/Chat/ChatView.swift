//
//  ChatView.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @State private var message = ""
    
    @State private var messages: [ChatMessage] = [
        .init(
            text: "Hey 👋",
            time: "10:21 AM",
            isSender: false,
            isRead: true
        ),
        
            .init(
                text: "Hi! How are you?",
                time: "10:22 AM",
                isSender: true,
                isRead: true
            ),
        
            .init(
                text: "I'm good. Working on SwiftUI.",
                time: "10:23 AM",
                isSender: false,
                isRead: true
            ),
        
            .init(
                text: "Nice! It looks amazing.",
                time: "10:24 AM",
                isSender: true,
                isRead: false
            )
    ]
    
    @FocusState private var isTyping: Bool
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView {
                
                LazyVStack(spacing: 12) {
                    
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.white)
            .scrollIndicators(.hidden)
            
            .onChange(of: messages.count) { _ in
                DispatchQueue.main.async {
                    scrollToBottom(proxy)
                }
            }

            .onChange(of: isTyping) { focused in
                guard focused else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    scrollToBottom(proxy)
                }
            }
            
            .safeAreaInset(edge: .bottom) {
                ChatInputView(message: $message, onSend: {
                    sendMessage()
                }, isTyping: _isTyping)
            }
        }
        .appNavigationBar(
            title: "Chat",
            leading: .back
        ) {
            router.pop()
        }
    }
    
    func sendMessage() {
        
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        
        messages.append(
            ChatMessage(
                text: trimmed,
                time: formattedTime(),
                isSender: true,
                isRead: false
            )
        )
        
        message = ""
        
        isTyping = true
    }
    
    func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        guard let last = messages.last else { return }

        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }
    
    func formattedTime() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        return formatter.string(from: Date())
    }
}

#Preview {
    ChatView()
}
