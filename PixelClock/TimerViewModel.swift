//
//  TimerViewModel.swift
//  PixelClock
//
//  Created for Pixel Clock V2
//

import Foundation
import SwiftUI

enum TimerState: Equatable {
    case task
    case `break`
    case longBreak
}

class TimerViewModel: ObservableObject {
    @Published var timerValue: Double = 25 * 60
    @Published var currentState: TimerState = .task
    @Published var timerRunning: Bool = false
    @Published var completedTasks: Int = 0
    
    let taskDuration: Double = 25
    let breakDuration: Double = 5
    let longBreakDuration: Double = 15
    
    func switchTo(_ state: TimerState) {
        currentState = state
        
        switch state {
        case .task:
            timerValue = taskDuration * 60
        case .break:
            timerValue = breakDuration * 60
        case .longBreak:
            timerValue = longBreakDuration * 60
        }
    }
}