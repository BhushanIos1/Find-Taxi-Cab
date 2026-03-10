//
//  GetCabScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 09/03/26.
//

import SwiftUI

struct GetCabScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    let pickupAddress: String
    let destinationAddress: String
    let disability: String
    let numberOfPassenger: Int
    
    @State private var selectedDate: Date = .now
    @State private var bookingType: BookingType = .immediate
    @State private var passengers: Int
    @State private var showDatePicker = false
    
    @State private var showAlert = false
    
    init(
        pickupAddress: String,
        destinationAddress: String,
        disability: String,
        numberOfPassenger: Int
    ) {
        self.pickupAddress = pickupAddress
        self.destinationAddress = destinationAddress
        self.disability = disability
        self.numberOfPassenger = numberOfPassenger
        _passengers = State(initialValue: numberOfPassenger)
    }
    
    private let taxiCars: [TaxiCarModel] = [
        TaxiCarModel(image: "taxi1", price: 20.70, seats: 4, metric: 2),
        TaxiCarModel(image: "taxi1", price: 32.50, seats: 6, metric: 3),
        TaxiCarModel(image: "taxi1", price: 15.30, seats: 4, metric: 1)
    ]
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            headerView
            
            buttonSection
            
            disabilityText
            
            vehicleList
        }
        .appNavigationBar(
            title: "Select Cab",
            leading: .back
        ) {
            router.pop()
        }
        .sheet(isPresented: $showDatePicker) {
            datePickerSheet
        }
        .overlay {
            
            ZStack {
                
                if showAlert {
                    
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    AndroidAlertView(
                        message: "Sorry No Vehicle Available. Please Try Later",
                        buttonTitle: "OK"
                    ) {
                        withAnimation {
                            showAlert = false
                            router.popTo(.home)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showAlert)
        }
    }
}

private extension GetCabScreen {
    
    var headerView: some View {
        
        BookingPreviewHeader(
            pickupAddress: .constant(pickupAddress),
            destinationAddress: .constant(destinationAddress),
            selectedDate: $selectedDate,
            selectedType: $bookingType,
            onAdvanceTap: { showDatePicker = true },
            showBookingType: true
        )
        .padding(20)
    }
}

private extension GetCabScreen {
    
    var disabilityText: some View {
        
        Text(disability.isEmpty ? "No Special Needs" : disability)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

private extension GetCabScreen {
    
    var vehicleList: some View {
        
        ScrollView(showsIndicators: false) {
            
            LazyVStack(spacing: 20) {
                ForEach(taxiCars) { car in
                    
                    Button {
                        handleCarSelection(car)
                    } label: {
                        TaxiCarCell(car: car)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

private extension GetCabScreen {
    
    func handleCarSelection(_ car: TaxiCarModel) {
        print("Selected Car:", car)
        showAlert = true
    }
}

private extension GetCabScreen {
    
    var datePickerSheet: some View {
        
        VStack(spacing: 10) {
            
            Text("Select Pickup Time")
                .font(AppFont.font(.medium, size: 16))
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            
            Button {
                showDatePicker = false
            } label: {
                Text("Done")
                    .primaryButtonStyle()
            }
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private extension GetCabScreen {
    
    var buttonSection: some View {
        
        Button {
            
        } label: {
            Text("ESTIMATED FARE")
                .font(AppFont.font(.medium, size: 18))
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(colorScheme == .dark ? Color.white : Color.black)
        }
    }
}

#Preview {
    GetCabScreen(pickupAddress: "", destinationAddress: "", disability: "", numberOfPassenger: 2)
}
