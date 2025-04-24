//
//  ContentView.swift
//  PixelClock
//
//  Created by FreePixelGames on 2025/4/24.
//

import SwiftUI
import AppKit
import AVFoundation

struct ContentView: View {
    @State private var timerValue: Double = 25 * 60 // 25分钟转换为秒
    @State private var taskDuration: Double = 25 // 分钟
    @State private var breakDuration: Double = 5 // 分钟
    @State private var longBreakDuration: Double = 15 // 分钟
    @State private var timerRunning = false
    @State private var timer: Timer? = nil
    @State private var currentState = "Task" // "Task", "Break", "Long Break"
    @State private var completedTasks: Int = 0 // 跟踪完成的任务数
    @State private var volume: Double = 0.5 {
        didSet {
            // 如果当前正在播放声音，实时更新音量
            if let player = Self.player {
                player.volume = Float(volume)
            }
        }
    }
    @State private var soundEnabled = true
    @State private var soundTimer: Timer? = nil
    private static var player: NSSound?
    @EnvironmentObject var appDelegate: AppDelegate // 添加这行

    var body: some View {
        VStack {
            Text("Pomodoro Timer")
                .font(.largeTitle)
                .padding()

            Text(currentState)
                .font(.title)
                .foregroundColor(currentState == "Task" ? .green : currentState == "Break" ? .blue : .orange)
                .padding()

            // 显示格式改为分:秒
            Text("\(Int(timerValue) / 60):\(String(format: "%02d", Int(timerValue) % 60))")
                .font(.system(size: 40))
                .padding()

            // 添加完成任务计数显示
            Text("Completed Tasks: \(completedTasks)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()

            HStack(spacing: 20) { // 添加间距
                Button(action: startPauseTimer) {
                    Text(timerRunning ? "Pause" : "Start")
                        .frame(width: 80) // 固定宽度
                        .padding(.vertical, 8) // 只添加垂直方向的内边距
                }
                .buttonStyle(CustomButtonStyle(color: .blue))
                .focusable(false) // 禁用焦点
                .contentShape(Rectangle()) // 确保点击区域正确
                
                Button(action: stopTimer) {
                    Text("Stop")
                        .frame(width: 80) // 固定宽度
                        .padding(.vertical, 8) // 只添加垂直方向的内边距
                }
                .buttonStyle(CustomButtonStyle(color: .red))
                .focusable(false) // 禁用焦点
                .contentShape(Rectangle())
            }
            .padding(.vertical) // 为按钮组添加垂直间距

            VStack {
                Text("Task Duration: \(Int(taskDuration)) min")
                Slider(value: $taskDuration, in: 1...60, step: 1)
                    .padding()
                    .disabled(timerRunning)
                    .focusable(false)
                    .onChange(of: taskDuration) { oldValue, newValue in // 使用新的onChange语法
                        if currentState == "Task" && !timerRunning {
                            DispatchQueue.main.async {
                                timerValue = newValue * 60
                            }
                        }
                    }

                Text("Break Duration: \(Int(breakDuration)) min")
                Slider(value: $breakDuration, in: 1...30, step: 1)
                    .padding()
                    .disabled(timerRunning)
                    .focusable(false)
                    .onChange(of: breakDuration) { oldValue, newValue in
                        if currentState == "Break" && !timerRunning {
                            DispatchQueue.main.async {
                                timerValue = newValue * 60
                            }
                        }
                    }

                Text("Long Break Duration: \(Int(longBreakDuration)) min")
                Slider(value: $longBreakDuration, in: 5...30, step: 1)
                    .padding()
                    .disabled(timerRunning)
                    .focusable(false)
                    .onChange(of: longBreakDuration) { oldValue, newValue in
                        if currentState == "Long Break" && !timerRunning {
                            DispatchQueue.main.async {
                                timerValue = newValue * 60
                            }
                        }
                    }
            }

            VStack {
                Toggle(isOn: $soundEnabled) {
                    Text("Enable Sound")
                }
                .padding()

                Text("Volume: \(Int(volume * 100))%")  // 添加音量百分比显示
                Slider(value: $volume, in: 0...1, step: 0.01)
                    .padding()
            }
        }
        .padding()
        .background(WindowAccessor())
    }

    func startPauseTimer() {
        stopSound() // 确保停止声音
        if timerRunning {
            timer?.invalidate()
            timer = nil
        } else {
            let totalTime = timerValue
            updateMenuBarProgress(totalTime: totalTime, remainingTime: timerValue)
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if self.timerValue > 0 {
                    self.timerValue -= 1
                    self.updateMenuBarProgress(totalTime: totalTime, remainingTime: self.timerValue)
                } else {
                    timer.invalidate()
                    self.timer = nil
                    if self.soundEnabled {
                        self.playSound() // 时间到时播放声音
                    }
                    self.updateMenuBarProgress(totalTime: totalTime, remainingTime: 0)
                    self.updateState()
                }
            }
            
            // 确保计时器在主运行循环中运行
            RunLoop.main.add(timer!, forMode: .common)
        }
        timerRunning.toggle()
    }

    func stopTimer() {
        stopSound() // 确保停止声音
        timer?.invalidate()
        timer = nil
        timerRunning = false
        completedTasks = 0
        currentState = "Task"
        timerValue = taskDuration * 60  // 转换为秒
        
        updateMenuBarProgress(totalTime: 1, remainingTime: 1)
    }

    func updateState() {
        if currentState == "Task" {
            completedTasks += 1
            if completedTasks >= 4 {
                currentState = "Long Break"
                timerValue = longBreakDuration * 60  // 转换为秒
                completedTasks = 0
            } else {
                currentState = "Break"
                timerValue = breakDuration * 60  // 转换为秒
            }
        } else if currentState == "Break" {
            currentState = "Task"
            timerValue = taskDuration * 60  // 转换为秒
        } else {
            currentState = "Task"
            timerValue = taskDuration * 60  // 转换为秒
        }
        timerRunning = false
    }

    func playSound() {
        if soundEnabled {
            stopSound()
            
            // 尝试加载自定义声音
            if let soundURL = Bundle.main.url(forResource: "alert", withExtension: "wav"),
               let sound = NSSound(contentsOf: soundURL, byReference: true) {
                sound.volume = Float(volume)  // 使用当前音量设置
                Self.player = sound
                Self.player?.play()
                
                // 创建重复播放的计时器
                soundTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    Self.player?.stop()  // 先停止当前播放
                    Self.player?.volume = Float(volume)  // 更新音量
                    Self.player?.play()  // 重新播放
                }
                
                // 确保计时器在主运行循环中运行
                if let timer = soundTimer {
                    RunLoop.main.add(timer, forMode: .common)
                }
            } else {
                // 如果找不到自定义声音，使用系统声音
                fallbackBeep()
            }
        }
    }
    
    private func fallbackBeep() {
        NSSound.beep()
        soundTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let systemSound = NSSound(named: NSSound.Name("Tink")) {
                systemSound.volume = Float(volume)  // 设置系统声音的音量
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

    // 新增辅助方法
    private func updateMenuBarProgress(totalTime: Double, remainingTime: Double) {
        print("ContentView updating progress: total=\(totalTime), remaining=\(remainingTime)")
        if let menuBarController = appDelegate.menuBarController {
            menuBarController.updateProgress(totalTime: totalTime, remainingTime: remainingTime)
        } else {
            print("MenuBarController not found in AppDelegate!")
        }
    }
}

// 在 ContentView 外部添加自定义按钮样式
struct CustomButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// 新增一个专门处理声音的类
class SoundPlayer {
    func play(volume: Float) {
        DispatchQueue.main.async {
            if let sound = NSSound(named: NSSound.Name("Tink")) {
                sound.volume = volume
                sound.play()
            } else {
                NSSound.beep()
            }
        }
    }
}

// 预览支持
#Preview {
    ContentView()
        .environmentObject(AppDelegate()) // 添加这行以支持预览
}
