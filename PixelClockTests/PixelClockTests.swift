//
//  PixelClockTests.swift
//  PixelClockTests
//
//  Created by FreePixelGames on 2025/4/23.
//

import Testing
@testable import PixelClock

struct PixelClockTests {

    @Test func testTimerViewModelInitialization() async throws {
        let viewModel = TimerViewModel()
        
        #expect(viewModel.timerValue == 25 * 60)
        #expect(viewModel.currentState == .task)
        #expect(viewModel.timerRunning == false)
        #expect(viewModel.completedTasks == 0)
    }

    @Test func testSwitchToTaskMode() async throws {
        let viewModel = TimerViewModel()
        viewModel.switchTo(.task)
        
        #expect(viewModel.timerValue == 25 * 60)
        #expect(viewModel.currentState == .task)
    }

    @Test func testSwitchToBreakMode() async throws {
        let viewModel = TimerViewModel()
        viewModel.switchTo(.break)
        
        #expect(viewModel.timerValue == 5 * 60)
        #expect(viewModel.currentState == .break)
    }

    @Test func testSwitchToLongBreakMode() async throws {
        let viewModel = TimerViewModel()
        viewModel.switchTo(.longBreak)
        
        #expect(viewModel.timerValue == 15 * 60)
        #expect(viewModel.currentState == .longBreak)
    }

    @Test func testSwitchMultipleModes() async throws {
        let viewModel = TimerViewModel()
        
        viewModel.switchTo(.task)
        #expect(viewModel.timerValue == 25 * 60)
        
        viewModel.switchTo(.break)
        #expect(viewModel.timerValue == 5 * 60)
        
        viewModel.switchTo(.longBreak)
        #expect(viewModel.timerValue == 15 * 60)
        
        viewModel.switchTo(.task)
        #expect(viewModel.timerValue == 25 * 60)
    }

}
