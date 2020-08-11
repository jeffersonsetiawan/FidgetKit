//
//  ContentView.swift
//  FidgetKit
//
//  Created by Jefferson Setiawan on 11/08/20.
//

import Combine
import SwiftUI

struct ContentView: View {
    @ObservedObject var state: AppState
    @State var selectedFidgetId: Int? = nil
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        NavigationView {
            List(state.fidgets.indices, id: \.self) { index in
                NavigationLink(
                    destination: FidgetDetailView(fidget: $state.fidgets[index]),
                    tag: state.fidgets[index].id,
                    selection: $selectedFidgetId) {
                    FidgetListItem(fidget: $state.fidgets[index])
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Fidget Collection")
            .onAppear {
                guard let data = UserDefaults(suiteName: appGroup)?.value(forKey: "fidgets") as? Data else { return }
                state.fidgets = try! JSONDecoder().decode([Fidget].self, from: data)
            }
            .onOpenURL(perform: { url in
                self.selectedFidgetId = state.fidgets.first(where: { $0.fidgetUrl == url})?.id
            })
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    guard let data = UserDefaults(suiteName: appGroup)?.value(forKey: "fidgets") as? Data else { return }
                    state.fidgets = try! JSONDecoder().decode([Fidget].self, from: data)
                case .inactive:
                    let data = try? JSONEncoder().encode(state.fidgets)
                    UserDefaults(suiteName: appGroup)?.setValue(data, forKey: "fidgets")
                case .background:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}

struct FidgetListItem: View {
    @Binding var fidget: Fidget
    var body: some View {
        VStack {
            Image(fidget.image)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .padding()
            HStack {
                Text(fidget.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                VStack(alignment: .leading) {
                    Text("Level: \(fidget.level)")
                        .font(.caption)
                    Text("Total Spin: \(fidget.totalSpin)")
                        .font(.caption)
                    if let lastDate = fidget.lastSpinDate {
                        Text("Last Spin: ")
                            .font(.caption) + Text(lastDate, style: .relative)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(state: .init(fidgets: [.batman]))
    }
}
