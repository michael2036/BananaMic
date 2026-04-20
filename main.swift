import Cocoa
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate, AVAudioRecorderDelegate {
    var statusItem: NSStatusItem!
    var audioRecorder: AVAudioRecorder?
    var isRecording = false
    
    var theMenu: NSMenu!
    var recordMenuItem: NSMenuItem!
    
    var timer: Timer?
    var flashState = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Use a fixed length to avoid resizing issues when the icon changes
        statusItem = NSStatusBar.system.statusItem(withLength: 22)
        
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(iconClicked(_:))
            // Listen to both left and right clicks
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            updateIcon()
        }
        
        constructMenu()
        
        // Request Microphone Permission preemptively
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                print("Microphone access granted.")
            } else {
                print("Microphone access denied.")
            }
        }
    }
    
    func constructMenu() {
        theMenu = NSMenu()
        
        theMenu.addItem(NSMenuItem(title: "Native Screen Capture", action: #selector(takeScreenshot), keyEquivalent: ""))
        theMenu.addItem(NSMenuItem.separator())
        
        recordMenuItem = NSMenuItem(title: "Quick Audio Record", action: #selector(startRecordingFromMenu), keyEquivalent: "")
        theMenu.addItem(recordMenuItem)
        theMenu.addItem(NSMenuItem.separator())
        
        theMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: ""))
    }
    
    @objc func iconClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        
        // Always show menu on right click
        if event?.type == .rightMouseUp {
            showMenu()
            return
        }
        
        // On left click:
        if isRecording {
            // Stop recording cleanly
            stopRecording()
        } else {
            // Show the menu
            showMenu()
        }
    }
    
    func showMenu() {
        statusItem.menu = theMenu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc func takeScreenshot() {
        let workspace = NSWorkspace.shared
        if let url = URL(string: "file:///System/Applications/Utilities/Screenshot.app") {
            let config = NSWorkspace.OpenConfiguration()
            workspace.openApplication(at: url, configuration: config, completionHandler: nil)
        }
    }
    
    @objc func startRecordingFromMenu() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        let fileManager = FileManager.default
        guard let downloadsDir = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = formatter.string(from: Date())
        let filename = "recording_\(dateString).m4a"
        let fileURL = downloadsDir.appendingPathComponent(filename)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            
            // Update Menu
            recordMenuItem.title = "Stop Recording..."
            
            // Start Icon Animation
            startTimer()
            
            print("Started recording to \(fileURL.path)")
        } catch {
            print("Failed to start recording: \(error)")
            let alert = NSAlert()
            alert.messageText = "Recording Failed"
            alert.informativeText = "Could not start audio recording. Make sure microphone permissions are granted in System Settings -> Privacy & Security -> Microphone."
            alert.runModal()
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        // Update Menu
        recordMenuItem.title = "Quick Audio Record"
        
        // Stop Icon Animation
        stopTimer()
        
        print("Stopped recording.")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            copyToClipboard(url: recorder.url)
        } else {
            print("Recording finished unsuccessfully.")
        }
    }
    
    func copyToClipboard(url: URL) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([url as NSURL])
        print("Copied to clipboard: \(url.path)")
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    // MARK: - Icon Drawing & Animation
    
    func getIcon(recording: Bool, flashOn: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        
        // Using drawingHandler ensures that NSColor.labelColor dynamically adapts
        // to Light/Dark mode changes in the menu bar in real-time.
        let image = NSImage(size: size, flipped: false) { rect in
            if #available(macOS 12.0, *) {
                let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
                if let gear = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
                    let drawRect = NSRect(x: (18 - gear.size.width)/2, y: (18 - gear.size.height)/2, width: gear.size.width, height: gear.size.height)
                    gear.isTemplate = true
                    gear.draw(in: drawRect)
                    NSColor.labelColor.set()
                    drawRect.fill(using: .sourceAtop)
                }
            } else {
                // Fallback for older macOS
                if let gear = NSImage(named: NSImage.advancedName) {
                    let drawRect = NSRect(x: 1, y: 1, width: 16, height: 16)
                    gear.draw(in: drawRect)
                }
            }
            
            if recording && flashOn {
                // Draw red dot in the exact center
                let dotRect = NSRect(x: 6, y: 6, width: 6, height: 6)
                let dotPath = NSBezierPath(ovalIn: dotRect)
                NSColor.systemRed.setFill()
                dotPath.fill()
            } else if !recording {
                // Draw a tiny dot to make it look like a lens/tool hub
                let dotRect = NSRect(x: 8.5, y: 8.5, width: 1, height: 1)
                let dotPath = NSBezierPath(ovalIn: dotRect)
                NSColor.labelColor.setFill()
                dotPath.fill()
            }
            
            return true
        }
        
        // We set isTemplate = false so the red dot keeps its color.
        // The drawingHandler + labelColor takes care of the dark/light mode adaptation.
        image.isTemplate = false
        return image
    }
    
    func updateIcon() {
        statusItem.button?.image = getIcon(recording: isRecording, flashOn: flashState)
    }
    
    func startTimer() {
        flashState = true
        updateIcon()
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.flashState.toggle()
            self.updateIcon()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        flashState = false
        updateIcon()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
