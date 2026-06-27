//
//  GetCabScreen.swift
//  Find Taxi Cab
//
//  Created by Bhushan Kumar on 09/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct GetCabScreen: View {
    
    @EnvironmentObject
    private var router: AppRouter
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @EnvironmentObject
    private var toastManager: ToastManager
    
    let fromLat: Double
    let fromLong: Double
    let toLat: Double
    let toLong: Double
    
    let pickupAddress: String
    let destinationAddress: String
    let disability: String
    let numberOfPassenger: Int
    
    @State private var selectedDate: Date = .now
    @State private var bookingType: BookingType = .immediate
    @State private var passengers: Int
    @State private var showDatePicker = false
    
    @State private var showAlert = false
    
    private var bookingDate: String {
        bookingType == .immediate
        ? Date().apiDate
        : selectedDate.apiDate
    }

    private var bookingTime: String {
        bookingType == .immediate
        ? Date().apiTime
        : selectedDate.apiTime
    }
    
    @StateObject
    private var viewModel = BookingViewModel()
    
    init(
        pickupAddress: String,
        destinationAddress: String,
        fromLat: Double,
        fromLong: Double,
        toLat: Double,
        toLong: Double,
        disability: String,
        numberOfPassenger: Int
    ) {
        self.pickupAddress = pickupAddress
        self.destinationAddress = destinationAddress
        self.fromLat = fromLat
        self.fromLong = fromLong
        self.toLat = toLat
        self.toLong = toLong
        self.disability = disability
        self.numberOfPassenger = numberOfPassenger
        _passengers = State(initialValue: numberOfPassenger)
    }

    var body: some View {
        
        ZStack {
            
            VStack(spacing: 0) {
                
                headerView
                
                buttonSection
                                
                vehicleList
            }
            
            if viewModel.isLoading {
                
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                
                LoadingIndicator(
                    animation: .circleTrim,
                    color: AppColors.primaryYellow,
                    size: .medium,
                    speed: .normal
                )
            }
        }
        .appNavigationBar(
            title: "Select Cab",
            leading: .back
        ) {
            router.pop()
        }
        .onAppear {
            loadVehicles()
        }
        .onChange(of: bookingType) { type in
            if type == .immediate {
                loadVehicles()
            } else {
                showDatePicker = true
            }
        }
        .onChange(of: viewModel.bookingState) { state in
            
            guard let state else { return }
            
            switch state {
                
            case .success(let message):
                
                toastManager.showToast(
                    type: .success,
                    title: "Success",
                    subtitle: message
                )
                
                viewModel.errorMessage = nil
                
            case .failure(let message):
                
                toastManager.showToast(
                    type: .error,
                    title: "Registration Failed",
                    subtitle: message
                )
            }
            
            DispatchQueue.main.async {
                viewModel.bookingState = nil
            }
        }
        .overlay(GlobalToastView().environmentObject(toastManager))
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
    
    private func loadVehicles() {

        viewModel.getVehicleList(
            latFrom: "\(fromLat)",
            longFrom: "\(fromLong)",
            latTo: "\(toLat)",
            longTo: "\(toLong)",
            date: bookingDate,
            time: bookingTime,
            passengers: "\(passengers)",
            specialNeed: disability
        )
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
                
                ForEach(viewModel.availableVehicles) { car in
                    
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
    
    func handleCarSelection(_ car: VehicleModel) {
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
                loadVehicles()
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
