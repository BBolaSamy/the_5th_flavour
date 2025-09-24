import SwiftUI

struct RoadTripSetupView: View {
    @StateObject private var roadTripService = RoadTripService()
    @State private var tripName = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var showingDatePicker = false
    @State private var selectedDateType: DateType = .start
    
    enum DateType {
        case start, end
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Start a Road Trip")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Organize your travel memories by trip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Form
                VStack(spacing: 20) {
                    // Trip Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trip Name")
                            .font(.headline)
                        
                        TextField("e.g., West Coast Adventure", text: $tripName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Date Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trip Dates")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            // Start Date
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    selectedDateType = .start
                                    showingDatePicker = true
                                }) {
                                    HStack {
                                        Text(startDate, style: .date)
                                        Spacer()
                                        Image(systemName: "calendar")
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // End Date
                            VStack(alignment: .leading, spacing: 4) {
                                Text("End Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    selectedDateType = .end
                                    showingDatePicker = true
                                }) {
                                    HStack {
                                        Text(endDate, style: .date)
                                        Spacer()
                                        Image(systemName: "calendar")
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Duration
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text("Duration: \(durationText)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Create Trip Button
                Button(action: createRoadTrip) {
                    HStack {
                        Image(systemName: "car.fill")
                        Text("Start Road Trip")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(tripName.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(tripName.isEmpty)
                .padding(.horizontal, 32)
                
                // Recent Trips
                if !roadTripService.allTrips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Trips")
                            .font(.headline)
                            .padding(.horizontal, 32)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(roadTripService.allTrips.prefix(3)) { trip in
                                    RecentTripCard(trip: trip) {
                                        roadTripService.currentTrip = trip
                                    }
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                    }
                }
            }
            .navigationTitle("Road Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Dismiss
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(
                    selectedDate: selectedDateType == .start ? $startDate : $endDate,
                    title: selectedDateType == .start ? "Start Date" : "End Date"
                )
            }
        }
    }
    
    private var durationText: String {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        if days == 1 {
            return "1 day"
        } else {
            return "\(days) days"
        }
    }
    
    private func createRoadTrip() {
        roadTripService.createRoadTrip(
            name: tripName,
            startDate: startDate,
            endDate: endDate
        )
        
        // Navigate to road trip view
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    title,
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RecentTripCard: View {
    let trip: RoadTrip
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                Text(trip.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(trip.duration) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "photo")
                        .font(.caption)
                    Text("\(trip.totalPhotos)")
                        .font(.caption)
                    
                    Spacer()
                    
                    Image(systemName: "book")
                        .font(.caption)
                    Text("\(trip.totalJournals)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 140, height: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RoadTripSetupView()
}
