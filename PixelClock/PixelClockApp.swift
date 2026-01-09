//
//  PixelClockApp.swift
//  PixelClock
//
//  Created by FreePixel (freepixel@rockstonegame.com) on 2025/4/23.
//

import SwiftUI
import AppKit

@main
struct PixelClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
        .defaultSize(width: 0, height: 0)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .windowSize) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .systemServices) {
                Button("Minimize") {
                    if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                        appDelegate.hidePopover()
                    }
                }
                .keyboardShortcut("w", modifiers: .command)
            }
        }
    }
}

class PopoverViewController: NSViewController {
    weak var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = NSHostingController(rootView: ContentView()
            .environmentObject(appDelegate!)
        )
        
        self.view = hostingController.view
        self.addChild(hostingController)
    }
}

// 负责处理菜单栏初始化的 AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var menuBarController: MenuBarController?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("AppDelegate: Initializing")
        
        DispatchQueue.main.async {
            self.setupPopover()
            self.menuBarController = MenuBarController(appDelegate: self)
            print("MenuBarController initialized")
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        
        guard let popover = popover else { return }
        
        popover.contentSize = NSSize(width: 530, height: 570)
        popover.behavior = .transient
        popover.animates = true
        
        let contentViewController = PopoverViewController()
        contentViewController.appDelegate = self
        popover.contentViewController = contentViewController
        
        // 根据系统外观设置 Popover 的外观
        let appearanceName = NSApp.effectiveAppearance.name
        popover.appearance = NSAppearance(named: appearanceName)
        
        // 监听系统主题切换
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            let newAppearance = NSApp.effectiveAppearance.name
            self?.popover?.appearance = NSAppearance(named: newAppearance)
        }
    }
    
    func showPopover() {
        guard let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            menuBarController?.showPopover()
        }
    }
    
    func hidePopover() {
        popover?.performClose(nil)
    }
}

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem
    private var currentProgress: Double = 0
    private var rightClickMenu: NSMenu
    private weak var appDelegate: AppDelegate?
    private var isDarkMode: Bool = false
    
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
        // Calculate progress value
        currentProgress = 1.0 - (remainingTime / totalTime)
        // Redraw immediately
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
            let progressColor: NSColor
            if isDarkMode {
                progressColor = NSColor(
                    red: 0.831,
                    green: 0.686,
                    blue: 0.215,
                    alpha: 1.0
                )
            } else {
                progressColor = NSColor.systemBlue
            }
            progressColor.setStroke()
            progressPath.stroke()
        }
        
        image.unlockFocus()
        
        // 移除 template 模式，这样可以显示实际颜色
        image.isTemplate = false
        
        // 更新状态栏图标
        statusItem.button?.image = image
    }
    
    func updateTheme(isDark: Bool) {
        isDarkMode = isDark
        drawProgress()
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
        appDelegate?.showPopover()
    }
    
    func showPopover() {
        guard let popover = appDelegate?.popover,
              let button = statusItem.button else { return }
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
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
