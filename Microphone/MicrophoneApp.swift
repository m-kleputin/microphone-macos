//
//  MicrophoneApp.swift
//  Microphone
//
//  Created by Mikhail Kleputin on 29.12.2023.
//

import SwiftUI
import Foundation

@main
struct MicrophoneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate;
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!;
    private var statusItem: NSStatusItem!
    private var isEnabledMic: Bool = true
    
    private let micEnabledImage = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "Microphone on")
    private let micDisabledImage = NSImage(systemSymbolName: "mic.slash.fill", accessibilityDescription: "Microphone off")
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = self.micEnabledImage
        self.toggleMicrophone(true)
        self.requestAccess()
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if (event.keyCode != 79) {
                return
            }
            self.isEnabledMic = !self.isEnabledMic
            self.toggleMicrophone(self.isEnabledMic)
            self.statusItem.button?.image = self.isEnabledMic ? self.micEnabledImage : self.micDisabledImage
        }
    }
    
    func requestAccess() -> Void {
        if (!AXIsProcessTrusted()) {
            CGRequestListenEventAccess()
        }
    }
    
    func toggleMicrophone( _ isEnabled: Bool ) {
        let enableScriptPath = Bundle.main.path(forResource: "global-enable-mic", ofType: "scpt")!
        let disableScriptPath = Bundle.main.path(forResource: "global-disable-mic", ofType: "scpt")!

        let task = Process()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [ isEnabled ? enableScriptPath : disableScriptPath ]
        task.launch()
    }
}
