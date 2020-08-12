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
    @State var isFirstLoad = true
    var body: some View {
        NavigationView {
            List(state.fidgets.indices, id: \.self) { index in
                NavigationLink(
                    destination: FidgetDetailView(fidget: $state.fidgets[index]),
                    tag: state.fidgets[index].id,
                    selection: $selectedFidgetId) {
                    FidgetListItem(fidget: $state.fidgets[index])
                }
            }
            .navigationTitle("Fidget Collection")
            .onAppear {
                guard isFirstLoad else { return }
                self.isFirstLoad = false
                self.loadData()
            }
            .onOpenURL(perform: { url in
                self.selectedFidgetId = state.fidgets.first(where: { $0.fidgetUrl == url})?.id
            })
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    self.loadData()
                case .inactive:
                    self.save()
                case .background:
                    break
                @unknown default:
                    break
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .SaveData)) { data in
                save()
            }
        }
    }
    
    func loadData() {
        guard let data = UserDefaults(suiteName: appGroup)?.value(forKey: "fidgets") as? Data else { return }
        state.fidgets = try! JSONDecoder().decode([Fidget].self, from: data)
    }
    
    func save() {
        let data = try? JSONEncoder().encode(state.fidgets)
        UserDefaults(suiteName: appGroup)?.setValue(data, forKey: "fidgets")
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
            HStack(spacing: 8) {
                Text(fidget.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
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

extension Notification.Name {
    static let SaveData = Notification.Name(rawValue: "SaveData")
}
