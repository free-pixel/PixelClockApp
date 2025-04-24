//
//  WindowAccessor.swift
//  PixelClock
//
//  Created by FreePixelGames on 2025/4/24.
//


import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        DispatchQueue.main.async {
            if let window = view.window {
                // 禁用关闭按钮
                window.standardWindowButton(.closeButton)?.isEnabled = false
                
                // 替换关闭行为
                window.delegate = context.coordinator
            }
        }
        
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, NSWindowDelegate {
        func windowShouldClose(_ sender: NSWindow) -> Bool {
            sender.miniaturize(nil) // 最小化窗口
            return false // 阻止默认关闭
        }
    }
}
