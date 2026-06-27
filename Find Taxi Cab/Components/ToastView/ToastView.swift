//
//  ToastView.swift
//  Find Taxi Cab Driver
//
//  Created by Bhushan Kumar on 08/04/26.
//

import SwiftUI

struct ToastView: View {
    
    let toastType: ToastType
    let title: String
    let subtitle: String?
    let onUndo: (() -> Void)?
    
    @State private var countdown: Int = 5
    @State private var progress: CGFloat = 1.0
    @State private var isUndoing: Bool = false
    @State private var showUndoMessage: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            if showUndoMessage {
                undoConfirmationView
            } else {
                toastContentView
                if !isUndoing && toastType == .info {
                    undoButtonView
                }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(uiColor: .tertiarySystemGroupedBackground) : .white)
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.15), radius: 12)
        .padding(.horizontal)
        .onAppear { startCountdown() }
    }
    
    private var toastContentView: some View {
        
        HStack(spacing: 10) {
            Image(systemName: toastType.icon)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(toastType.titleColor)
                .background(Circle().fill(toastType.backgroundColor).frame(width: 35, height: 35))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(AppFont.font(.semiBold, size: 16)).foregroundColor(toastType.titleColor)
                if let subtitle = subtitle {
                    Text(subtitle).font(AppFont.font(.regular, size: 14)).foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }
    
    private var undoButtonView: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2).frame(width: 30, height: 30)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(toastType.titleColor, lineWidth: 2)
                .rotationEffect(.degrees(-90))
                .frame(width: 30, height: 30)
                .animation(.linear(duration: 1), value: progress)
            Button(action: undoAction) {
                Image(systemName: "arrow.uturn.backward").foregroundColor(toastType.titleColor)
            }
        }
    }
    
    private var undoConfirmationView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            Text("Action has been undone").font(.headline).foregroundColor(.green)
            Spacer()
        }
    }
    
    private func startCountdown() {
        guard !isUndoing else { return }
        if countdown > -1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.linear(duration: 1)) {
                    countdown -= 1
                    progress = CGFloat(countdown) / 5.0
                }
                startCountdown()
            }
        } else {
            onUndo?()
        }
    }
    
    private func undoAction() {
        isUndoing = true
        showUndoMessage = true
        progress = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showUndoMessage = false
            onUndo?()
        }
    }
}
