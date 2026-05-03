//
//  PrettyHabitsWidgetBundle.swift
//  PrettyHabitsWidget
//
//  Created by Anna Giang on 3/5/2026.
//

import WidgetKit
import SwiftUI

@main
struct PrettyHabitsWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrettyHabitsWidget()
        PrettyHabitsWidgetControl()
        PrettyHabitsWidgetLiveActivity()
    }
}
