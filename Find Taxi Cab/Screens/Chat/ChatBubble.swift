//
//  ChatBubble.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI

struct ChatBubble: View {
    
    let message: ChatMessage
    
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
            .background(
                message.isSender
                ? AppColors.uberBlack
                : AppColors.uberLightGray
            )
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
    }
}
