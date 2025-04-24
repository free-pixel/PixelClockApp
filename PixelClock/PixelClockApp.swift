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
                .environmentObject(appDelegate)
                .background(VisualEffectView())
        }
        // 移除 .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 300, height: 720)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .windowSize) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .systemServices) {
                Button("Minimize") {
                    if let window = NSApplication.shared.windows.first {
                        window.miniaturize(nil)
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
            }
        }
    }
}

// 创建自定义窗口类来禁用关闭按钮
class NonClosableWindow: NSWindow {
    // 重写performClose方法，使其什么也不做
    override func performClose(_ sender: Any?) {
        // 不执行任何操作，这样点击关闭按钮不会有任何效果
    }
}

// 负责处理菜单栏初始化的 AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var menuBarController: MenuBarController?
    var mainWindow: NSWindow?
    private var windowDelegate: WindowDelegate?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("AppDelegate: Initializing")
        
        DispatchQueue.main.async {
            self.setupMainWindow()
            self.menuBarController = MenuBarController(appDelegate: self)
            print("MenuBarController initialized")
            self.mainWindow?.orderOut(nil)
        }
    }

    private func setupMainWindow() {
        // 使用我们的自定义窗口类
        mainWindow = NonClosableWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 720),
            styleMask: [.titled, .miniaturizable, .closable],
            backing: .buffered,
            defer: false
        )
        
        if let window = mainWindow {
            // 禁用关闭按钮，使其显示为灰色
            window.standardWindowButton(.closeButton)?.isEnabled = false
            
            window.title = "PixelClock"
            window.isReleasedWhenClosed = false
            window.canHide = true
            
            let contentView = ContentView()
                .environmentObject(self)
            
            window.contentView = NSHostingView(rootView: contentView)
            window.center()
            
            windowDelegate = WindowDelegate()
            window.delegate = windowDelegate
        }
    }
    
    // 添加一个空方法，用于关闭按钮的动作
    @objc private func doNothing() {
        // 什么也不做
    }
}

// 窗口代理类确保窗口不能被关闭
class WindowDelegate: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return false // 永远不允许窗口关闭
    }
    
    func windowWillClose(_ notification: Notification) {
        // 如果somehow窗口要关闭，改为最小化
        if let window = notification.object as? NSWindow {
            window.miniaturize(nil)
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
        
        rightClickMenu.addItem(NSMenuItem(title: "Show", action: #selector(showMainWindow), keyEquivalent: "s"))
        rightClickMenu.addItem(NSMenuItem.separator())
        rightClickMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleButtonClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
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
        
        if event.type == .rightMouseUp {
            statusItem.menu = rightClickMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            showMainWindow()
        }
    }
    
    @objc func showMainWindow() {
        if let existingWindow = NSApplication.shared.windows.first {
            NSApp.activate(ignoringOtherApps: true)
            
            if existingWindow.isMiniaturized {
                existingWindow.deminiaturize(nil)
            }
            
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        guard let window = appDelegate?.mainWindow else {
            print("Warning: Main window not found!")
            return
        }
        
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
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

// 添加毛玻璃效果背景
struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .windowBackground
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}