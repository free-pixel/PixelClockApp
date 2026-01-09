//
//  ContentView.swift
//  PixelClock
//
//  Created by FreePixel (freepixel@rockstonegame.com) on 2025/4/24.
//

import SwiftUI
import AppKit
import AVFoundation

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .popover
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var timer: Timer? = nil
    @State private var volume: Double = 0.5 {
        didSet {
            if let player = Self.player {
                player.volume = Float(volume)
            }
        }
    }
    @State private var soundEnabled = true
    @State private var soundTimer: Timer? = nil
    private static var player: NSSound?
    @EnvironmentObject var appDelegate: AppDelegate
    @Environment(\.colorScheme) var colorScheme
    @State private var isDebugDarkMode = false

    private let goldColor = Color(hex: "0xD4AF37")

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    var body: some View {
        VStack(spacing: 30) {
            PillTabSwitcher(selectedState: $viewModel.currentState)

            Text(stateText(for: viewModel.currentState))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(stateColor(for: viewModel.currentState))
                .contentTransition(.opacity)

            Text(formatTime(viewModel.timerValue))
                .font(.system(size: 72, weight: .regular, design: .monospaced))
                .fontDesign(.rounded)
                .contentTransition(.numericText(countsDown: true))
                .foregroundColor(colorScheme == .dark ? goldColor : .primary)
                .shadow(
                    color: colorScheme == .dark ? goldColor.opacity(0.3) : .clear,
                    radius: colorScheme == .dark ? 20 : 0,
                    x: 0,
                    y: 0
                )
                .shadow(
                    color: colorScheme == .dark ? goldColor.opacity(0.6) : .clear,
                    radius: colorScheme == .dark ? 5 : 0,
                    x: 0,
                    y: 0
                )

            Text("Completed Tasks: \(viewModel.completedTasks)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Button(action: startPauseTimer) {
                    Text(viewModel.timerRunning ? "Pause" : "Start")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? goldColor : .white)
                        .frame(width: 100, height: 44)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.blue)
                                .overlay(
                                    Capsule()
                                        .stroke(colorScheme == .dark ? goldColor : .clear, lineWidth: 2)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)

                Button(action: stopTimer) {
                    Text("Stop")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? goldColor : .white)
                        .frame(width: 100, height: 44)
                        .background(
                            Capsule()
                                .fill(colorScheme == .dark ? Color.black.opacity(0.8) : Color.red)
                                .overlay(
                                    Capsule()
                                        .stroke(colorScheme == .dark ? goldColor : .clear, lineWidth: 2)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }

            Spacer()

            VStack(spacing: 15) {
                Toggle(isOn: $soundEnabled) {
                    Text("Enable Sound")
                }
                .toggleStyle(SwitchToggleStyle())

                if soundEnabled {
                    HStack {
                        Text("Volume")
                        Slider(value: $volume, in: 0...1, step: 0.01)
                            .frame(maxWidth: 150)
                        Text("\(Int(volume * 100))%")
                            .font(.system(size: 12))
                            .frame(width: 30)
                    }
                }

                Button(action: {
                    isDebugDarkMode.toggle()
                }) {
                    Text("Theme: \(colorScheme == .dark ? "Dark" : "Light") \(isDebugDarkMode ? "(Debug Dark)" : "")")
                        .font(.system(size: 12))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .background(
            ZStack {
                if colorScheme == .dark || isDebugDarkMode {
                    Color.black.opacity(0.7)
                }
                VisualEffectView()
            }
        )
        .ignoresSafeArea()
    }

    private func stateText(for state: TimerState) -> String {
        switch state {
        case .task:
            return "Focus Time"
        case .break:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }

    private func stateColor(for state: TimerState) -> Color {
        switch state {
        case .task:
            return .green
        case .break:
            return .blue
        case .longBreak:
            return .orange
        }
    }

    func startPauseTimer() {
        stopSound()
        if viewModel.timerRunning {
            timer?.invalidate()
            timer = nil
        } else {
            let totalTime = viewModel.timerValue
            updateMenuBarProgress(totalTime: totalTime, remainingTime: viewModel.timerValue)
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if viewModel.timerValue > 0 {
                    viewModel.timerValue -= 1
                    updateMenuBarProgress(totalTime: totalTime, remainingTime: viewModel.timerValue)
                } else {
                    timer?.invalidate()
                    timer = nil
                    if soundEnabled {
                        playSound()
                    }
                    updateMenuBarProgress(totalTime: totalTime, remainingTime: 0)
                    updateState()
                }
            }
            
            RunLoop.main.add(timer!, forMode: .common)
        }
        viewModel.timerRunning.toggle()
    }

    func stopTimer() {
        stopSound()
        timer?.invalidate()
        timer = nil
        viewModel.timerRunning = false
        viewModel.completedTasks = 0
        viewModel.switchTo(.task)
        updateMenuBarProgress(totalTime: 1, remainingTime: 1)
    }

    func updateState() {
        if viewModel.currentState == .task {
            viewModel.completedTasks += 1
            if viewModel.completedTasks >= 4 {
                viewModel.switchTo(.longBreak)
                viewModel.completedTasks = 0
            } else {
                viewModel.switchTo(.break)
            }
        } else {
            viewModel.switchTo(.task)
        }
        viewModel.timerRunning = false
    }

    func playSound() {
        if soundEnabled {
            stopSound()
            
            if let soundURL = Bundle.main.url(forResource: "alert", withExtension: "wav"),
               let sound = NSSound(contentsOf: soundURL, byReference: true) {
                sound.volume = Float(volume)
                Self.player = sound
                Self.player?.play()
                
                soundTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    Self.player?.stop()
                    Self.player?.volume = Float(volume)
                    Self.player?.play()
                }
                
                if let timer = soundTimer {
                    RunLoop.main.add(timer, forMode: .common)
                }
            } else {
                fallbackBeep()
            }
        }
    }
    
    private func fallbackBeep() {
        NSSound.beep()
        soundTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let systemSound = NSSound(named: NSSound.Name("Tink")) {
                systemSound.volume = Float(volume)
                systemSound.play()
            } else {
                NSSound.beep()
            }
        }
        if let timer = soundTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopSound() {
        soundTimer?.invalidate()
        soundTimer = nil
        Self.player?.stop()
        Self.player = nil
    }

    private func updateMenuBarProgress(totalTime: Double, remainingTime: Double) {
        if let menuBarController = appDelegate.menuBarController {
            menuBarController.updateProgress(totalTime: totalTime, remainingTime: remainingTime)
        }
    }
}

struct PillTabSwitcher: View {
    @Binding var selectedState: TimerState

    var body: some View {
        HStack(spacing: 8) {
            PillButton(title: "25m", state: .task, selectedState: $selectedState)
            PillButton(title: "5m", state: .break, selectedState: $selectedState)
            PillButton(title: "15m", state: .longBreak, selectedState: $selectedState)
        }
        .padding(8)
        .background(
            Capsule()
                .fill(Color.primary.opacity(0.1))
        )
    }
}

struct PillButton: View {
    let title: String
    let state: TimerState
    @Binding var selectedState: TimerState

    var body: some View {
        Button(action: {
            selectedState = state
        }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var isSelected: Bool {
        selectedState == state
    }
}

#Preview {
    ContentView()
        .environmentObject(AppDelegate())
}