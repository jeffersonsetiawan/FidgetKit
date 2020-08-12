//
//  FidgetDetailView.swift
//  FidgetKit
//
//  Created by Jefferson Setiawan on 11/08/20.
//

import SwiftUI
import WidgetKit

struct FidgetDetailView: View {
    @Binding var fidget: Fidget
    @State var rotation: Double = 0
    @State var isRotating = false
    var body: some View {
        VStack {
            Image(fidget.image)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250, alignment: .center)
                .animation(.none)
                .rotationEffect(.init(degrees: rotation))
                .animation(isRotating ? Animation.easeInOut.repeatForever() : .default)
                .navigationTitle(fidget.name)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isRotating else { return }
                            self.rotation = Double(value.translation.height)
                        }
                        .onEnded { value in
                            guard !isRotating else { return }
                            if value.translation.height > 200 {
                                self.rotation = 360 * 10
                                self.isRotating = true
                                self.fidget.rotate()
                                WidgetCenter.shared.reloadTimelines(ofKind: "FidgetWidget")
                                NotificationCenter.default.post(Notification(name: Notification.Name.SaveData))
                            } else {
                                self.rotation = 0
                                self.isRotating = false
                            }
                        }
                ).padding()
            if fidget.timeNeededToFinishRotation > 0 {
                Text("Time needed rotation to finish: ") + Text(Date(timeIntervalSinceNow: fidget.timeNeededToFinishRotation), style: .relative)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isRotating = fidget.isInRotating
                    if isRotating {
                        self.rotation = 360 * 50
                    }
                }
            }
        }
    }
}

struct FidgetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FidgetDetailView(fidget: .constant(.batman))
    }
}
