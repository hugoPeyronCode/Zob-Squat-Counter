//
//  SquatActivityAttributes.swift
//  SquatWidgetExtensionExtension
//
//  Created by Hugo Peyron on 22/04/2025.
//

import ActivityKit
import SwiftUI

struct SquatActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var count: Int
        var goal: Int
        var startTime: Date
        var isActive: Bool
    }

    var name: String
}
