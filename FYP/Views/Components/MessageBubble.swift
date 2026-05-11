//
//  MessageBubble.swift
//  FYP
//
//  Created by Sharjeel Ahmed on 12/02/2026.
//

import SwiftUI

struct MessageBubble: View {
    var message: ChatMessage
    var bubbleWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .top) {
            if message.isCurrentUser { Spacer() }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(message.text)
                    .font(.system(size: 16))
                    .foregroundColor(message.isCurrentUser ? message.actualColor : .black)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Button {
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                            .foregroundColor(message.isCurrentUser ? .white.opacity(0.8) : .gradientStart)
                    }
                    
                    Spacer()
                    
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor(message.isCurrentUser ? .white.opacity(0.9) : .black)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill( Gradient(colors: message.isCurrentUser ?  [Color.gradientend, Color.gradientStart] : [Color.white, Color.gray.opacity(0.8)]))
                    .shadow(color: .black.opacity(0.05),
                        radius: 5, x: 0, y: 2)
                           
            )
            .frame(maxWidth: bubbleWidth, alignment: message.isCurrentUser ? .trailing : .leading)
            
            if !message.isCurrentUser { Spacer() }
        }
    }
}



