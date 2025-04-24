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
    // 将 mainWindow 改为 internal 访问级别
    var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("AppDelegate: Initializing")
        
        // 确保主窗口已创建
        DispatchQueue.main.async {
            self.setupMainWindow()
            self.menuBarController = MenuBarController(appDelegate: self)
            print("MenuBarController initialized")
            
            // 初始时隐藏窗口
            self.mainWindow?.orderOut(nil)
        }
    }

    private func setupMainWindow() {
        // 创建窗口
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 720),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        if let window = mainWindow {
            // 设置窗口标题和基本属性
            window.title = "PixelClock"
            window.isReleasedWhenClosed = false
            window.canHide = true
            
            // 创建内容视图
            let contentView = ContentView()
                .environmentObject(self)
            
            // 设置内容视图
            window.contentView = NSHostingView(rootView: contentView)
            
            // 配置窗口属性
            window.styleMask.remove(.resizable)
            window.center()
            window.delegate = self
        }
    }
}

// 修改窗口代理方法
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            window.miniaturize(nil)
        }
    }
    
    func windowDidMiniaturize(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            window.setIsVisible(false)
        }
    }
    
    func windowDidDeminiaturize(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            window.makeKeyAndOrderFront(nil)
        }
    }
}

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem
    private var currentProgress: Double = 0
    private var rightClickMenu: NSMenu
    private weak var appDelegate: AppDelegate?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        rightClickMenu = NSMenu()
        
        super.init()
        
        // 配置右键菜单
        rightClickMenu.addItem(NSMenuItem(title: "Show", action: #selector(showMainWindow), keyEquivalent: "s"))
        rightClickMenu.addItem(NSMenuItem.separator())
        rightClickMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        // 配置状态栏按钮
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleButtonClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // 初始化时绘制进度为0的图标
        drawProgress()
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
            // 直接显示右键菜单，不需要额外的 performClick
            statusItem.menu = rightClickMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil  // 菜单显示后清除引用，这样左键点击仍然可以正常工作
        } else {
            showMainWindow()
        }
    }
    
    @objc func showMainWindow() {
        // 激活应用程序
        NSApp.activate(ignoringOtherApps: true)
        
        if let window = appDelegate?.mainWindow {
            if window.isMiniaturized {
                window.deminiaturize(nil)
            }
            
            // 确保窗口可见并居中
            window.setIsVisible(true)
            window.center()
            
            // 将窗口带到前台
            window.orderFrontRegardless()
            
            // 强制激活窗口
            NSApp.activate(ignoringOtherApps: true)
        } else {
            print("Warning: Main window not found!")
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
