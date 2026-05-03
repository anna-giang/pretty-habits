//
//  PrettyHabitsWidgetLiveActivity.swift
//  PrettyHabitsWidget
//
//  Created by Anna Giang on 3/5/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PrettyHabitsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PrettyHabitsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrettyHabitsWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PrettyHabitsWidgetAttributes {
    fileprivate static var preview: PrettyHabitsWidgetAttributes {
        PrettyHabitsWidgetAttributes(name: "World")
    }
}

extension PrettyHabitsWidgetAttributes.ContentState {
    fileprivate static var smiley: PrettyHabitsWidgetAttributes.ContentState {
        PrettyHabitsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PrettyHabitsWidgetAttributes.ContentState {
         PrettyHabitsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PrettyHabitsWidgetAttributes.preview) {
   PrettyHabitsWidgetLiveActivity()
} contentStates: {
    PrettyHabitsWidgetAttributes.ContentState.smiley
    PrettyHabitsWidgetAttributes.ContentState.starEyes
}
