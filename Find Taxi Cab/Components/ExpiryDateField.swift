//
//  ExpiryDateField.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 28/02/26.
//

import SwiftUI

struct ExpiryDateField: View {
    
    @Binding var month: String
    @Binding var year: String
    
    @State private var showMonthPicker = false
    @State private var showYearPicker = false
    
    private let months =
    (1...12).map { String(format: "%02d", $0) }
    
    private let years =
    (0...15).map {
        String(Calendar.current.component(.year, from: Date()) + $0)
    }
    
    var body: some View {
        
        HStack(spacing: 8) {
            
            // MONTH
            dropdownField(
                title: "MM",
                value: month
            ) {
                showMonthPicker = true
            }
            
            // YEAR
            dropdownField(
                title: "YYYY",
                value: year
            ) {
                showYearPicker = true
            }
        }
        .sheet(isPresented: $showMonthPicker) {
            pickerSheet(
                title: "Select Month",
                data: months
            ) { month = $0 }
        }
        .sheet(isPresented: $showYearPicker) {
            pickerSheet(
                title: "Select Year",
                data: years
            ) { year = $0 }
        }
    }
}

private extension ExpiryDateField {
    
    func dropdownField(
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            HStack {
                
                Spacer()
                
                Text(value.isEmpty ? title : value)
                    .foregroundStyle(
                        value.isEmpty ? AppColors.textFieldUnderlineColor : .black
                    )
                
                Spacer()
            }
            .padding()
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(
                        AppColors.primaryYellow,
                        lineWidth: 1
                    )
            )
        }
    }
}

private extension ExpiryDateField {
    
    func pickerSheet(
        title: String,
        data: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {
        
        NavigationStack {
            
            List(data, id: \.self) { item in
                
                Button(item) {
                    onSelect(item)
                    
                    UIApplication.shared
                        .connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?
                        .windows
                        .first?
                        .rootViewController?
                        .dismiss(animated: true)
                }
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    ExpiryDateField(month: .constant("Feb"), year: .constant("2025"))
}
