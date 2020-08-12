//
//  Fidget.swift
//  FidgetKit
//
//  Created by Jefferson Setiawan on 11/08/20.
//

import Foundation

class AppState: ObservableObject {
    var fidgets: [Fidget]
    internal init(fidgets: [Fidget]) {
        self.fidgets = fidgets
    }
}

public let appGroup = "group.jeffersonsetiawan.FidgetKit"

struct Fidget: Equatable, Hashable, Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    var rotationPerSpin: Int
    var rotationTimePerSpin: TimeInterval
    var level: Int
    var lastSpinDate: Date?
    var spinCount: Int = 0
    var isLimitedEdition = false
    
    var isInRotating: Bool {
        guard let lastSpinDate = lastSpinDate else { return false }
        return lastSpinDate.addingTimeInterval(rotationTimePerSpin) > Date()
    }
    
    var timeNeededToFinishRotation: TimeInterval {
        guard let lastSpinDate = lastSpinDate, isInRotating else { return 0 }
        return rotationTimePerSpin - (Date().timeIntervalSince1970 - lastSpinDate.timeIntervalSince1970)
    }
    
    var totalSpin: Int {
        guard let lastSpinDate = lastSpinDate else {
            return 0
        }
        let now = Date()
        if lastSpinDate.addingTimeInterval(rotationTimePerSpin) > now {
            let currentSpinRotate = (now.timeIntervalSinceNow - lastSpinDate.timeIntervalSinceNow) / Double(rotationTimePerSpin) * Double(rotationPerSpin)
            return rotationPerSpin * (spinCount - 1) + Int(currentSpinRotate)
        }
        return rotationPerSpin * spinCount
    }
    
    var fidgetUrl: URL {
        return URL(string: "fidget://\(id)")!
    }
    
    mutating func rotate() {
        spinCount += 1
        lastSpinDate = Date()
    }
}

extension Fidget {
    static let batman: Self = .init(
        id: 1,
        name: "Batman Fidget",
        image: "batman_fidget",
        rotationPerSpin: 2000,
        rotationTimePerSpin: 60,
        level: 1,
        lastSpinDate: Date(timeIntervalSinceNow: -9),
        spinCount: 1,
        isLimitedEdition: true
    )
    
    static let red: Self = .init(
        id: 2,
        name: "Red Fidget",
        image: "red_fidget",
        rotationPerSpin: 50,
        rotationTimePerSpin: 20,
        level: 1
    )
    
    static let blue: Self = .init(
        id: 3,
        name: "Blue Fidget",
        image: "blue_fidget",
        rotationPerSpin: 50,
        rotationTimePerSpin: 20,
        level: 1
    )
    
    static let green: Self = .init(
        id: 4,
        name: "Green Fidget",
        image: "green_fidget",
        rotationPerSpin: 50,
        rotationTimePerSpin: 10,
        level: 1
    )
    
    static let orange: Self = .init(
        id: 5,
        name: "Orange Fidget",
        image: "orange_fidget",
        rotationPerSpin: 50,
        rotationTimePerSpin: 10,
        level: 1
    )
    
    static let rainbow: Self = .init(
        id: 6,
        name: "Rainbow Fidget",
        image: "rainbow_fidget",
        rotationPerSpin: 100,
        rotationTimePerSpin: 40,
        level: 1
    )
}
