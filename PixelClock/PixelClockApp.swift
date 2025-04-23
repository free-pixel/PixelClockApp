//
//  PixelClockApp.swift
//  PixelClock
//
//  Created by FreePixelGames on 2025/4/23.
//

import SwiftUI
import AppKit

@main
struct PixelClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 300, height: 720)
                .fixedSize()
                .environmentObject(appDelegate) // 添加这行，将 AppDelegate 注入到环境中
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 300, height: 720)
    }
}

// 负责处理菜单栏初始化的 AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("AppDelegate: Creating MenuBarController") // 添加调试输出
        self.menuBarController = MenuBarController()
        print("AppDelegate: MenuBarController created: \(self.menuBarController != nil)") // 添加调试输出
        
        if let window = NSApplication.shared.windows.first {
            window.styleMask.remove(.resizable)
            window.setContentSize(NSSize(width: 300, height: 720))
            window.center()
        }
    }
}

class MenuBarController {
    private(set) var statusItem: NSStatusItem
    private var currentProgress: Double = 0
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        setupMenuBar()
    }
    
    func updateProgress(totalTime: Double, remainingTime: Double) {
        // 计算进度值
        currentProgress = 1.0 - (remainingTime / totalTime)
        // 立即重绘
        drawProgress()
    }
    
    private func drawProgress() {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // 清除背景，使其透明
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        if let context = NSGraphicsContext.current {
            context.shouldAntialias = true
            
            let bounds = NSRect(origin: .zero, size: size)
            let center = NSPoint(x: bounds.midX, y: bounds.midY)
            let radius = min(bounds.width, bounds.height) / 2 - 2
            
            // 绘制背景圆环
            let backgroundPath = NSBezierPath()
            backgroundPath.lineWidth = 2.0
            backgroundPath.appendArc(withCenter: center,
                                   radius: radius,
                                   startAngle: 0,
                                   endAngle: 360)
            NSColor.gray.withAlphaComponent(0.3).setStroke()
            backgroundPath.stroke()
            
            // 绘制进度圆环
            let progressPath = NSBezierPath()
            progressPath.lineWidth = 2.0
            progressPath.appendArc(withCenter: center,
                                 radius: radius,
                                 startAngle: 90,
                                 endAngle: 90 - (360 * CGFloat(currentProgress)),
                                 clockwise: true)
            NSColor.red.setStroke()
            progressPath.stroke()
        }
        
        image.unlockFocus()
        
        // 移除 template 模式，这样可以显示实际颜色
        image.isTemplate = false
        
        // 更新状态栏图标
        statusItem.button?.image = image
    }
    
    func setupMenuBar() {
        drawProgress()
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show", action: #selector(showMainWindow), keyEquivalent: "s"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

struct SettingsView: View {
    @State private var taskDuration: Double = 25
    @State private var breakDuration: Double = 5
    @State private var longBreakDuration: Double = 15

    var body: some View {
        Form {
            Section(header: Text("Task Duration")) {
                HStack {
                    Slider(value: $taskDuration, in: 1...60, step: 1)
                    Text("\(Int(taskDuration)) min")
                }
            }

            Section(header: Text("Break Duration")) {
                HStack {
                    Slider(value: $breakDuration, in: 1...30, step: 1)
                    Text("\(Int(breakDuration)) min")
                }
            }

            Section(header: Text("Long Break Duration")) {
                HStack {
                    Slider(value: $longBreakDuration, in: 1...60, step: 1)
                    Text("\(Int(longBreakDuration)) min")
                }
            }
        }
        .padding()
    }
}
