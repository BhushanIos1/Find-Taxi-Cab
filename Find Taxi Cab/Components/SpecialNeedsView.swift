//
//  SpecialNeedsView.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 08/03/26.
//

import SwiftUI

struct SpecialNeedsView: View {
    
    @State private var specialNeed: SpecialNeedOption = .no
    @Binding var selectedDisability: DisabilityOption?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Do you have special needs?")
                .font(AppFont.font(.regular, size: 14))
            
            VStack(alignment: .leading, spacing: 16) {
                
                Menu {
                    
                    ForEach(DisabilityOption.allCases, id: \.self) { option in
                        
                        Button {
                            specialNeed = .yes
                            selectedDisability = option
                        } label: {
                            
                            HStack {
                                Text(option.rawValue)
                                
                                if selectedDisability == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                    
                } label: {
                    radioItem(
                        title: yesTitle,
                        type: .yes
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .tint(.black)
                
                Button {
                    specialNeed = .no
                    selectedDisability = nil
                } label: {
                    radioItem(
                        title: "No",
                        type: .no
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

extension SpecialNeedsView {
    
    private var yesTitle: String {
        if let disability = selectedDisability {
            return "Yes (\(disability.rawValue))"
        }
        return "Yes"
    }
    
    private func radioItem(title: String, type: SpecialNeedOption) -> some View {
        
        HStack(spacing: 8) {
            
            ZStack {
                
                Circle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: 16, height: 16)
                
                if specialNeed == type {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(title)
                .font(AppFont.font(.regular, size: 14))
                .foregroundColor(.primary)
        }
    }
}

enum SpecialNeedOption {
    case yes
    case no
}

enum DisabilityOption: String, CaseIterable {
    case blind = "Blind"
    case alzheimer = "Alzheimer"
    case dementia = "Dementia"
    case epilepsy = "Epilepsy"
    case wheelchair = "Wheel Chair"
}

#Preview {
    SpecialNeedsView(selectedDisability: .constant(.none))
}
