//
//  ChatView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 04/07/26.
//

import SwiftUI
import IQKeyboardManagerSwift

struct ChatView: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    let bookingId: String
    
    @StateObject
    private var viewModel: ChatViewModel
    
    @State private var message = ""
    
    @FocusState private var isTyping: Bool
    
    init(bookingId: String) {
        self.bookingId = bookingId
        _viewModel = StateObject(
            wrappedValue: ChatViewModel(bookingId: bookingId, mySenderType: "customer")
        )
    }
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
            ZStack {
                
                if viewModel.messages.isEmpty, !viewModel.isLoadingInitial {
                    emptyState
                } else {
                    thread
                }
                
                if viewModel.isLoadingInitial, viewModel.messages.isEmpty {
                    ProgressView()
                        .tint(AppColors.primaryYellow)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemBackground))
            .onChange(of: viewModel.messages) { _ in
                scrollToBottom(proxy)
            }
            .onChange(of: isTyping) { focused in
                
                guard focused else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    scrollToBottom(proxy)
                }
            }
            // A plain `safeAreaInset` bottom bar is the standard, idiomatic
            // SwiftUI way to keep a fixed nav bar in place while only this
            // region moves for the keyboard — and it Just Works once
            // `IQKeyboardManager` isn't also fighting it (see `onAppear` below).
            .safeAreaInset(edge: .bottom) {
                
                ChatInputView(message: $message, onSend: {
                    viewModel.send(message)
                    message = ""
                }, isTyping: _isTyping)
            }
        }
        .appNavigationBar(
            title: "Chat",
            leading: .back
        ) {
            router.pop()
        }
        .onAppear {
            viewModel.startPolling()
            
            // `IQKeyboardManager` is enabled app-wide (`AppDelegate`) and works
            // by translating the *whole* containing view controller's frame on
            // focus — entirely outside SwiftUI's own layout system, and outside
            // anything expressible from inside a SwiftUI view. No amount of
            // `.ignoresSafeArea`, manual padding, or a dedicated hosting
            // controller changes that; the only real point of control is its own
            // on/off switch, so this screen owns it for exactly as long as it's
            // visible. Every other screen in the app is completely unaffected —
            // the toggle flips back the moment Chat closes.
            IQKeyboardManager.shared.isEnabled = false
        }
        .onDisappear {
            // Nothing to watch once the thread is off screen, and the loop would
            // otherwise keep hitting the server for the life of the app.
            viewModel.stopPolling()
            
            IQKeyboardManager.shared.isEnabled = true
        }
        .alert(
            "Not Sent",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private extension ChatView {
    
    var thread: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 12) {
                
                ForEach(viewModel.messages) { message in
                    ChatBubble(message: message)
                        .id(message.id)
                }
            }
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
    
    var emptyState: some View {
        
        VStack(spacing: 12) {
            
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 42))
                .foregroundStyle(AppColors.primaryYellow)
            
            Text("No messages yet")
                .font(AppFont.font(.medium, size: 18))
            
            Text("Send your driver a message — where you're standing, or anything they need to know.")
                .font(AppFont.font(.regular, size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        
        guard let last = viewModel.messages.last else { return }
        
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }
}

#Preview {
    ChatView(bookingId: "1161")
}
