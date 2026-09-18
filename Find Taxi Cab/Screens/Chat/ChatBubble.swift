//
//  ChatBubble.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI

struct ChatBubble: View {
    
    let message: ChatMessage
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        
        HStack {
            
            if message.isSender {
                Spacer(minLength: 70)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(message.text)
                    .font(AppFont.font(.regular, size: 16))
                
                    .foregroundStyle(
                        message.isSender
                        ? .white
                        : .black
                    )
                
                HStack(spacing: 5) {
                    
                    Spacer()
                    
                    Text(message.time)
                        .font(AppFont.font(.regular, size: 11))
                        .foregroundStyle(
                            message.isSender
                            ? .white.opacity(0.7)
                            : .gray
                        )
                    
                    if message.isSender {
                        ChatDoubleTick(
                            isRead: message.isRead
                        )
                    }
                }
            }
            .padding(.horizontal,16)
            .padding(.vertical,12)
            .background(senderBubbleColor)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
            )
            
            if !message.isSender {
                Spacer(minLength: 70)
            }
        }
        .padding(.horizontal,16)
        // A message still in flight is dimmed, so "sent" and "sending" don't
        // look the same.
        .opacity(message.isPending ? 0.55 : 1)
    }
}

private extension ChatBubble {

    /// `uberBlack`/`uberLightGray` are literal hex colors, not system-adaptive
    /// ones — in dark mode the sent bubble's `#000000` background became
    /// indistinguishable from the screen's own near-black background, so every
    /// sent message rendered as invisible white text floating with no bubble at
    /// all. The received bubble was unaffected only because `#F3F3F3` happens to
    /// read fine against either background by coincidence.
    var senderBubbleColor: Color {

        guard message.isSender else {
            return AppColors.uberLightGray
        }

        return colorScheme == .dark
            ? Color(red: 0.16, green: 0.16, blue: 0.17)
            : AppColors.uberBlack
    }
}
