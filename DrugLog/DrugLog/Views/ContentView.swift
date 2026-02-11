//
//  ContentView.swift
//  DrugLog
//
//  Main view for the Drug Log application.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "pills.fill")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 60))
                    .padding()
                
                Text("Drug Log")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track your medications")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
                
                Spacer()
                    .frame(height: 50)
                
                VStack(spacing: 20) {
                    Text("Features:")
                        .font(.headline)
                    
                    FeatureRow(icon: "clock.fill", title: "Track medication times")
                    FeatureRow(icon: "bell.fill", title: "Set reminders")
                    FeatureRow(icon: "chart.bar.fill", title: "View history")
                    FeatureRow(icon: "heart.fill", title: "Monitor adherence")
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Drug Log")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
