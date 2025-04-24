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
        print("AppDelegate: Initializing")
        
        // 确保主窗口已创建
        DispatchQueue.main.async {
            self.menuBarController = MenuBarController()
            print("MenuBarController initialized")
            
            // 配置主窗口
            if let window = NSApplication.shared.windows.first {
                print("Configuring main window")
                window.styleMask.remove(.resizable)
                window.setContentSize(NSSize(width: 300, height: 720))
                window.center()
                
                // 初始时隐藏窗口
                window.orderOut(nil)
            } else {
                print("Warning: Main window not found during initialization")
            }
        }
    }
}

class MenuBarController: NSObject { // 继承 NSObject 以支持 selector
    private(set) var statusItem: NSStatusItem
    private var currentProgress: Double = 0
    private var rightClickMenu: NSMenu // 存储右键菜单
    
    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // 创建右键菜单
        rightClickMenu = NSMenu()
        rightClickMenu.addItem(NSMenuItem(title: "Show", action: #selector(showMainWindow), keyEquivalent: "s"))
        rightClickMenu.addItem(NSMenuItem.separator())
        rightClickMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        super.init()
        
        // 配置状态栏按钮
        if let button = statusItem.button {
            // 设置初始图标
            drawProgress()
            
            // 设置按钮事件监听
            button.target = self
            button.action = #selector(handleButtonClick(_:))
            
            // 确保按钮可以接收鼠标事件
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
            // 移除默认菜单
            statusItem.menu = nil
        }
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
    
    @objc private func handleButtonClick(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        print("Button clicked with event type: \(event.type.rawValue)")
        
        if event.type == .rightMouseUp {
            statusItem.button?.performClick(nil) // 触发右键菜单
            rightClickMenu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: statusItem.button!)
        } else {
            showMainWindow()
        }
    }
    
    @objc func showMainWindow() {
        print("Attempting to show main window")
        
        // 激活应用程序
        NSApp.activate(ignoringOtherApps: true)
        
        // 查找并显示主窗口
        if let window = NSApplication.shared.windows.first {
            print("Window found, showing it")
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
            
            // 确保窗口在屏幕上可见
            if let screen = NSScreen.main {
                let centerPoint = NSPoint(
                    x: screen.frame.midX - window.frame.width / 2,
                    y: screen.frame.midY - window.frame.height / 2
                )
                window.setFrameOrigin(centerPoint)
            }
            
            // 强制窗口成为关键窗口
            window.makeKey()
        } else {
            print("No window found!")
        }
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
