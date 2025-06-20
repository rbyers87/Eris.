import UIKit
import MLX
import MLXRandom
import MLXNN

class MemoryManager {
    static let shared = MemoryManager()
    
    private var memoryWarningObserver: NSObjectProtocol?
    private var observers: [MemoryPressureObserver] = []
    
    // Cache references
    private weak var modelManager: ModelManager?
    
    private init() {
        setupMemoryWarningObserver()
    }
    
    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Setup
    
    private func setupMemoryWarningObserver() {
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }
    
    // MARK: - Memory Warning Handling
    
    private func handleMemoryWarning() {
        print("⚠️ Memory Warning Received - Starting cleanup")
        
        // 1. Reduce MLX GPU cache limit
        let currentLimit = 20 * 1024 * 1024 // 20MB default
        let reducedLimit = 10 * 1024 * 1024 // 10MB under pressure
        MLX.GPU.set(cacheLimit: reducedLimit)
        print("✓ Reduced GPU cache limit from \(currentLimit/1024/1024)MB to \(reducedLimit/1024/1024)MB")
        
        // 2. Clear any image caches
        URLCache.shared.removeAllCachedResponses()
        print("✓ Cleared URL cache")
        
        // 3. Notify observers to clear their caches
        notifyObservers()
        
        // 4. Force garbage collection
        autoreleasepool {
            // This helps release any autoreleased objects
        }
        
        // 5. Log memory usage
        logMemoryUsage()
    }
    
    // MARK: - Observer Pattern
    
    func addObserver(_ observer: MemoryPressureObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: MemoryPressureObserver) {
        observers.removeAll { $0 === observer }
    }
    
    private func notifyObservers() {
        observers.forEach { observer in
            observer.didReceiveMemoryWarning()
        }
    }
    
    // MARK: - Memory Usage Monitoring
    
    func logMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let usedMemoryMB = Double(info.resident_size) / 1024.0 / 1024.0
            print("📊 Current Memory Usage: \(String(format: "%.1f", usedMemoryMB)) MB")
        }
    }
    
    // MARK: - Manual Memory Management
    
    func performLowMemoryCleanup() {
        handleMemoryWarning()
    }
    
    func resetGPUCacheLimit() {
        // Reset to default limit
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        print("✓ Reset GPU cache limit to 20MB")
    }
}

// MARK: - Memory Pressure Observer Protocol

protocol MemoryPressureObserver: AnyObject {
    func didReceiveMemoryWarning()
}