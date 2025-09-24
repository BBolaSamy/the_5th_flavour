import SwiftUI
import MapKit
import CoreLocation

struct CitySearchView: View {
    @Binding var selectedCity: String
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var showingLocationPermission = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search for a city...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { newValue in
                            if newValue.count >= 2 {
                                searchForCities(query: newValue)
                            } else {
                                searchResults = []
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                            searchResults = []
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                // Search Results
                if isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Searching...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No cities found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try searching for a different city name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("Search for a city")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Type at least 2 characters to search for cities")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchResults, id: \.self) { mapItem in
                        CitySearchResultRow(mapItem: mapItem) {
                            selectedCity = mapItem.name ?? ""
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchForCities(query: String) {
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                isSearching = false
                
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    return
                }
                
                guard let response = response else { return }
                
                // Filter results to focus on cities and major locations
                let filteredResults = response.mapItems.filter { mapItem in
                    guard let name = mapItem.name?.lowercased() else { return false }
                    let placemark = mapItem.placemark
                    
                    // Filter for cities, towns, and major locations
                    let isCity = name.contains("city") || 
                                name.contains("town") || 
                                name.contains("village") ||
                                placemark.locality != nil ||
                                placemark.administrativeArea != nil
                    
                    return isCity && !name.contains("airport") && 
                           !name.contains("station") && 
                           !name.contains("mall")
                }
                
                searchResults = Array(filteredResults.prefix(10))
            }
        }
    }
}

struct CitySearchResultRow: View {
    let mapItem: MKMapItem
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mapItem.name ?? "Unknown Location")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(formatAddress(placemark: mapItem.placemark))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAddress(placemark: MKPlacemark) -> String {
        var components: [String] = []
        
        if let locality = placemark.locality {
            components.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }
        
        if let country = placemark.country {
            components.append(country)
        }
        
        return components.joined(separator: ", ")
    }
}

#Preview {
    CitySearchView(selectedCity: .constant(""))
}
