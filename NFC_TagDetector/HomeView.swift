//
//  HomeView.swift
//  NFC_TagDetector
//
//  Created by George Saleip on 23.04.25.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Title
                        Text("🌍 My Memory Map")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Region Grid (stubbed for now)
                        Text("📍 Regions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(["Lazio", "Sicilia", "Bavaria", "Tokyo"], id: \.self) { region in
                                VStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(height: 100)
                                        .overlay(Text(region))
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Recent Memories
                        Text("🕓 Recent Memories")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { _ in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 80)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }

                // NFC Scan Button
                Button(action: {
                    print("📶 Simulate NFC Scan")
                }) {
                    HStack {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Scan NFC")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
