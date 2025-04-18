//
//  SquatWidget.swift
//  SquatWidgetExtension
//
//  Created on 18/04/2025.
//

import WidgetKit
import SwiftUI

struct SquatWidget: Widget {
    let kind: String = "SquatWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SquatTimelineProvider()) { entry in
            SquatWidgetView(entry: entry)
                .fontDesign(.monospaced)
        }
        .configurationDisplayName("Squat Counter")
        .description("Track your daily squats progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Preview for widget gallery
struct SquatWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Small widget preview
            SquatWidgetView(entry: SquatEntry.sampleEntry(widgetFamily: .systemSmall))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .fontDesign(.monospaced)

            // Medium widget preview
            SquatWidgetView(entry: SquatEntry.sampleEntry(widgetFamily: .systemMedium))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .fontDesign(.monospaced)

            // Large widget preview
            SquatWidgetView(entry: SquatEntry.sampleEntry(widgetFamily: .systemLarge))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .fontDesign(.monospaced)
        }
    }
}
