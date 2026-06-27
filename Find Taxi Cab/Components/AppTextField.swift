//
//  AppTextField.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct AppTextField: View {
    
    // MARK: - Properties
    
    let title: String
    @Binding var text: String
    var error: String? = nil
    var keyboard: UIKeyboardType = .default
    var foregroundColor: Color = .black
    
    @FocusState
    private var isFocused: Bool
    
    private var shouldFloat: Bool {
        isFocused || !text.isEmpty
    }
    
    // MARK: - UI
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            ZStack(alignment: .leading) {
                
                // Floating Placeholder
                Text(title)
                    .foregroundStyle(
                        error != nil
                        ? Color.red
                        : (isFocused ? AppColors.primaryYellow : AppColors.textFieldUnderlineColor)
                    )
                    .font(
                        shouldFloat
                        ? AppFont.font(.regular, size: 14)
                        : AppFont.font(.regular, size: 18)
                    )
                    .offset(y: shouldFloat ? -20 : 0)
                    .scaleEffect(
                        shouldFloat ? 0.9 : 1,
                        anchor: .leading
                    )
                    .animation(.easeInOut(duration: 0.2),
                               value: shouldFloat)
                
                TextField("", text: $text)
                    .keyboardType(keyboard)
                    .focused($isFocused)
                    .font(AppFont.font(.regular, size: 18))
                    .tint(AppColors.primaryYellow)
                    .foregroundStyle(foregroundColor)
                    .padding(.top, shouldFloat ? 12 : 0)
            }
            .frame(height: 44)
            
            // Underline
            Rectangle()
                .frame(height: 1.0)
                .foregroundStyle(underlineColor)
                .animation(.easeInOut(duration: 0.2),
                           value: isFocused)
            
            // Error Message
            if let error {
                Text(error)
                    .font(AppFont.font(.regular, size: 12))
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: error)
    }
}

private extension AppTextField {
    
    var underlineColor: Color {
        
        if error != nil {
            return .red
        }
        
        return isFocused
        ? AppColors.primaryYellow
        : AppColors.textFieldUnderlineColor
    }
}

#Preview {
    AppTextField(title: "Name", text: .constant(""), foregroundColor: .black)
}

struct AppPasswordField: View {
    
    // MARK: - Properties
    
    let title: String
    @Binding var password: String
    var error: String? = nil
    
    @FocusState
    private var isFocused: Bool
    
    @State
    private var isSecure: Bool = true
    
    var foregroundColor: Color = .black
    
    private var shouldFloat: Bool {
        isFocused || !password.isEmpty
    }
    
    // MARK: - UI
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 2) {
            
            ZStack(alignment: .leading) {
                
                // Floating Placeholder
                Text(title)
                    .foregroundStyle(
                        error != nil
                        ? Color.red
                        : (isFocused
                           ? AppColors.primaryYellow
                           : AppColors.textFieldUnderlineColor)
                    )
                    .font(
                        shouldFloat
                        ? AppFont.font(.regular, size: 14)
                        : AppFont.font(.regular, size: 18)
                    )
                    .offset(y: shouldFloat ? -20 : 0)
                    .scaleEffect(
                        shouldFloat ? 0.9 : 1,
                        anchor: .leading
                    )
                    .animation(.easeInOut(duration: 0.2),
                               value: shouldFloat)
                
                HStack {
                    
                    Group {
                        if isSecure {
                            SecureField("", text: $password)
                        } else {
                            TextField("", text: $password)
                        }
                    }
                    .focused($isFocused)
                    .font(AppFont.font(.regular, size: 18))
                    .tint(AppColors.primaryYellow)
                    .foregroundStyle(foregroundColor)
                    
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName:
                                isSecure
                              ? "eye.slash"
                              : "eye")
                        .foregroundStyle(foregroundColor)
                    }
                }
                .padding(.top, shouldFloat ? 12 : 0)
            }
            .frame(height: 44)
            
            // Underline
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(underlineColor)
            
            // Error
            if let error {
                Text(error)
                    .font(AppFont.font(.regular, size: 12))
                    .foregroundColor(.red)
            }
        }
        .animation(.easeInOut, value: error)
    }
}

private extension AppPasswordField {
    
    var underlineColor: Color {
        
        if error != nil {
            return .red
        }
        
        return isFocused
        ? AppColors.primaryYellow
        : AppColors.textFieldUnderlineColor
    }
}
