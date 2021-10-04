import Foundation

public final class ForestKit {

    public static let instance = ForestKit()

    public var tag: String?

    var trees = [Tree]()

    /// Add a new logging tree.
    public func plant(_ tree: Tree) {
        if tree === self {
            fatalError("You cannot plant the Forest as a tree...")
        }
        trees.append(tree)
    }

    /// Adds new logging trees.
    public func plant(_ trees: Tree...) {
        trees.forEach { plant($0) }
    }

    /// Remove a planted tree.
    public func uproot(_ tree: Tree) {
        trees = trees.filter { $0 !== tree }
    }

    /// Remove all planted trees.
    public func uprootAll() {
        trees.removeAll()
    }

    /// Return a copy of all planted `trees`.
    public func forest() -> [Tree] {
        trees.map { $0 }
    }

    /// Return the number of `trees` in the forest
    public var treeCount: Int {
        trees.count
    }

    /// Set a tag for use on the logging call.
    public func tag(_ tag: String) -> ForestKit {
        self.tag = tag
        return self
    }

}

extension ForestKit {

    public enum Priority: String, CustomStringConvertible {
        case `default`
        case info
        case debug
        case error
        case fault

        public var description: String {
            switch self {
            case .default: return "[Default]"
            case .info: return "[Info]"
            case .debug: return "[Debug]"
            case .error: return "[Error]"
            case .fault: return "[Fault]"
            }
        }
    }

}

extension ForestKit {

    public func log(priority: Priority, tag: String?, message: String, error: Error?) {
        trees.forEach { $0.log(priority: priority, tag: tag, message: message, error: error) }
    }

    public func isLoggable(tag: String?, priority: Priority) -> Bool { true }

    /// Log a verbose message.
    public func log(_ message: String?) {
        trees.forEach { $0.log(message) }
        tag = nil
    }

    public func log(message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        log(message())
    }

    /// Log a verbose exception and a message.
    public func log(_ error: Error?, with message: String?) {
        trees.forEach { $0.log(error, with: message) }
        tag = nil
    }

    public func log(_ error: Error?, message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        log(error, with: message())
    }

    /// Log a verbose exception.
    public func log(_ error: Error?) {
        trees.forEach { $0.log(error) }
        tag = nil
    }

    /// Log a debug message.
    public func d(_ message: String?) {
        trees.forEach { $0.d(message) }
        tag = nil
    }

    public func d(_ message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        d(message())
    }

    /// Log a debug exception and a message.
    public func d(_ error: Error?, with message: String?) {
        trees.forEach { $0.d(error, with: message) }
        tag = nil
    }

    /// Log a debug exception and a message.
    public func d(_ error: Error?, with message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        d(error, with: message())
    }

    /// Log a debug exception.
    public func d(_ error: Error?) {
        trees.forEach { $0.d(error) }
        tag = nil
    }

    /// Log an info message.
    public func i(_ message: String?) {
        trees.forEach { $0.i(message) }
        tag = nil
    }

    public func i(_ message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        i(message())
    }

    /// Log an info exception and a message.
    public func i(_ error: Error?, with message: String?) {
        trees.forEach { $0.i(error, with: message) }
        tag = nil
    }

    public func i(_ error: Error?, with message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        i(error, with: message())
    }

    /// Log an info exception.
    public func i(_ error: Error?) {
        trees.forEach { $0.i(error) }
        tag = nil
    }

    /// Log a fault message.
    public func f(_ message: String?) {
        trees.forEach { $0.f(message) }
        tag = nil
    }

    public func f(_ message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        f(message())
    }

    /// Log a fault exception and a message.
    public func f(_ error: Error?, with message: String?) {
        trees.forEach { $0.f(error, with: message) }
        tag = nil
    }

    public func f(_ error: Error?, with message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        f(error, with: message())
    }

    /// Log a fault exception.
    public func f(_ error: Error?) {
        trees.forEach { $0.f(error) }
        tag = nil
    }

    /// Log an error message.
    public func e(_ message: String?) {
        trees.forEach { $0.e(message) }
        tag = nil
    }

    public func e(_ message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        e(message())
    }

    /// Log an error exception and a message.
    public func e(_ error: Error?, with message: String?) {
        trees.forEach { $0.e(error, with: message) }
        tag = nil
    }

    public func e(_ error: Error?, with message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        e(error, with: message())
    }

    /// Log an error exception.
    public func e(_ error: Error?) {
        trees.forEach { $0.e(error) }
        tag = nil
    }

    /// Log a fault message.
    public func wtf(_ message: String?) {
        f(message)
    }

    public func wtf(_ message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        f(message())
    }

    /// Log a fault exception and a message.
    public func wtf(_ error: Error?, with message: String?) {
        f(error, with: message)
    }

    public func wtf(_ error: Error?, with message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        f(error, with: message())
    }

    /// Log a fault exception.
    public func wtf(_ error: Error?) {
        f(error)
    }

    /// Log at `priority` a message.
    public func log(_ priority: ForestKit.Priority, with message: String?) {
        trees.forEach { $0.log(priority, with: message) }
        tag = nil
    }

    public func log(_ priority: ForestKit.Priority, with message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        log(priority, with: message())
    }

    /// Log at `priority` an exception and a message.
    public func log(priority: ForestKit.Priority, error: Error?, message: String?) {
        trees.forEach { $0.log(priority: priority, error: error, message: message) }
        tag = nil
    }

    public func log(priority: ForestKit.Priority, error: Error?, message: () -> String?) {
        guard !trees.isEmpty else {
            return
        }
        log(priority: priority, error: error, message: message())
    }

    /// Log at `priority` an exception.
    public func log(_ priority: ForestKit.Priority, with error: Error?) {
        trees.forEach { $0.log(priority, with: error) }
        tag = nil
    }

}

/// Internal protocol to set the API for the tree, See `Tree`.
public protocol Heartwood {

    func log(priority: ForestKit.Priority, tag: String?, message: String, error: Error?)

    func isLoggable(tag: String?, priority: ForestKit.Priority) -> Bool

    /// Log a default message.
    func log(_ message: String?)

    /// Log a default exception and a message.
    func log(_ error: Error?, with message: String?)

    /// Log a default exception.
    func log(_ error: Error?)

    /// Log a debug message.
    func d(_ message: String?)

    /// Log a debug exception and a message.
    func d(_ error: Error?, with message: String?)

    /// Log a debug exception.
    func d(_ error: Error?)

    /// Log an info message.
    func i(_ message: String?)

    /// Log an info exception and a message.
    func i(_ error: Error?, with message: String?)

    /// Log an info exception.
    func i(_ error: Error?)

    /// Log a fault message.
    func f(_ message: String?)

    /// Log a fault exception and a message.
    func f(_ error: Error?, with message: String?)

    /// Log a fault exception.
    func f(_ error: Error?)

    /// Log an error message.
    func e(_ message: String?)

    /// Log an error exception and a message.
    func e(_ error: Error?, with message: String?)

    /// Log an error exception.
    func e(_ error: Error?)

    /// Log a fault message.
    func wtf(_ message: String?)

    /// Log a fault exception and a message.
    func wtf(_ error: Error?, with message: String?)

    /// Log a fault exception.
    func wtf(_ error: Error?)

    /// Log at `priority` a message.
    func log(_ priority: ForestKit.Priority, with message: String?)

    /// Log at `priority` an exception and a message.
    func log(priority: ForestKit.Priority, error: Error?, message: String?)

    /// Log at `priority` an exception.
    func log(_ priority: ForestKit.Priority, with error: Error?)
}

public protocol Tree: AnyObject, Heartwood { }

extension Tree where Self: AnyObject {

    public func isLoggable(tag: String?, priority: ForestKit.Priority) -> Bool {
        true
    }

    /// Log a default message.
    public func log(_ message: String?) {
        prepareLog(.default, nil, message)
    }

    /// Log a default exception and a message.
    public func log(_ error: Error?, with message: String?) {
        prepareLog(.default, error, message)
    }

    /// Log a default exception.
    public func log(_ error: Error?) {
        prepareLog(.default, error, nil)
    }

    /// Log a default message.
    public func d(_ message: String?) {
        prepareLog(.debug, nil, message)
    }

    /// Log an debug exception and a message.
    public func d(_ error: Error?, with message: String?) {
        prepareLog(.debug, error, message)
    }

    /// Log a debug exception.
    public func d(_ error: Error?) {
        prepareLog(.debug, error, nil)
    }

    /// Log an info message.
    public func i(_ message: String?) {
        prepareLog(.info, nil, message)
    }

    /// Log an info exception and a message.
    public func i(_ error: Error?, with message: String?) {
        prepareLog(.info, error, message)
    }

    /// Log an info exception.
    public func i(_ error: Error?) {
        prepareLog(.info, error, nil)
    }

    /// Log a fault message.
    public func f(_ message: String?) {
        prepareLog(.fault, nil, message)
    }

    /// Log a fault exception and a message.
    public func f(_ error: Error?, with message: String?) {
        prepareLog(.fault, error, message)
    }

    /// Log a fault exception.
    public func f(_ error: Error?) {
        prepareLog(.fault, error, nil)
    }

    /// Log an error message.
    public func e(_ message: String?) {
        prepareLog(.error, nil, message)
    }

    /// Log an error exception and a message.
    public func e(_ error: Error?, with message: String?) {
        prepareLog(.error, error, message)
    }

    /// Log an error exception.
    public func e(_ error: Error?) {
        prepareLog(.error, error, nil)
    }

    /// Log an fault message.
    public func wtf(_ message: String?) {
        f(message)
    }

    /// Log an assert exception and a message.
    public func wtf(_ error: Error?, with message: String?) {
        f(error, with: message)
    }

    /// Log an assert exception.
    public func wtf(_ error: Error?) {
        f(error)
    }

    /// Log at `priority` a message.
    public func log(_ priority: ForestKit.Priority, with message: String?) {
        prepareLog(priority, nil, message)
    }

    /// Log at `priority` an exception and a message.
    public func log(priority: ForestKit.Priority, error: Error?, message: String?) {
        prepareLog(priority, error, message)
    }

    /// Log at `priority` an exception.
    public func log(_ priority: ForestKit.Priority, with error: Error?) {
        prepareLog(priority, error, nil)
    }

    private func prepareLog(_ priority: ForestKit.Priority, _ error: Error?, _ message: String?) {
        // Consume tag even when message is not loggable so that next message is correctly tagged.
        let tag = ForestKit.instance.tag
        if !isLoggable(tag: tag, priority: priority) {
            return
        }

        guard let message = message, message.count > 0 else {
            guard let error = error else {
                // Do not log if there is no error and message
                return
            }
            log(priority: priority, tag: tag, message: String(describing: error), error: error)
            return
        }

        log(priority: priority, tag: tag, message: message, error: error)
    }

}
