import Foundation

public final class ForestKit {

    public static let instance = ForestKit()

    public var tag: String?

    var trees = [Tree]()

    /// Add a new logging tree.
    public func plant(_ tree: Tree) {
        if trees.contains(where: { $0 === tree }) {
            fatalError("You have already planted this tree. \(tree)")
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

    public enum Priority: String, Codable, CaseIterable {
        case `default` = "[Default]"
        case info = "[Info]"
        case debug = "[Debug]"
        case error = "[Error]"
        case fault = "[Fault]"
        case wtf = "[WTF]"
    }

}

public typealias ForestKitMessage = () -> String

extension ForestKit {

    public func log(priority: Priority, tag: String?, message: String, error: Error?) {
        trees.forEach { $0.log(priority: priority, tag: tag, message: message, error: error) }
    }

    public func isLoggable(tag: String?, priority: Priority) -> Bool { true }

    private func prepareLog(_ priority: Priority, _ error: Error?, _ message: @autoclosure () -> String?) {
        // Only log is there are trees to log and isLoggable is true. There is no need to do String interpolation if not needed.
        guard !trees.isEmpty, isLoggable(tag: tag, priority: priority) else {
            // Consume tag even when message is not loggable so that next message is correctly tagged.
            tag = nil
            return
        }

        guard let message = message(), message.count > 0 else {
            guard let error = error else {
                tag = nil
                return
            }
            // If no message then put the error as the message so there is a message.
            log(priority: priority, tag: tag, message: String(describing: error), error: error)
            tag = nil
            return
        }

        log(priority: priority, tag: tag, message: message, error: error)
        tag = nil
    }

    /// Log a `default` exception and a message.
    public func log(_ error: Error? = nil, _ message: @autoclosure () -> String?) {
        prepareLog(.default, error, message())
    }

    /// Log an optional `debug`exception and a message.
    public func d(_ error: Error?, _ message: @autoclosure () -> String?) {
        prepareLog(.debug, error, message())
    }

    /// Log a `debug` message.
    public func d(_ message: @autoclosure () -> String?) {
        d(nil, message())
    }

    /// Log an optional `info` exception and an optional and a message.
    public func i(_ error: Error?, _ message: @autoclosure () -> String?) {
        prepareLog(.info, error, message())
    }

    /// Log a `info` message.
    public func i(_ message: @autoclosure () -> String?) {
        i(nil, message())
    }

    /// Log an optional `fault` exception and and a message.
    public func f(_ error: Error?, _ message: @autoclosure () -> String?) {
        prepareLog(.fault, error, message())
    }

    /// Log a`fault`message.
    public func f(_ message: @autoclosure () -> String?) {
        f(nil, message())
    }

    /// Log an optional `error` exception and and a message.
    public func e(_ error: Error?, _ message: @autoclosure () -> String?) {
        prepareLog(.error, error, message())
    }

    /// Log an `error` message.
    public func e(_ message: @autoclosure () -> String?) {
        e(nil, message())
    }

    /// Log an optional `wtf` exception and a message.
    public func wtf(_ error: Error?, _ message: @autoclosure () -> String) {
        prepareLog(.wtf, error, message())
    }

    /// Log a `wtf` message.
    public func wtf(_ message: @autoclosure () -> String) {
        wtf(nil, message())
    }
}

/// Internal protocol to set the API for the tree, See `Tree`.
public protocol Heartwood {

    func log(priority: ForestKit.Priority, tag: String?, message: String, error: Error?)

    func isLoggable(tag: String?, priority: ForestKit.Priority) -> Bool
}

public protocol Tree: AnyObject, Heartwood { }

extension Tree where Self: AnyObject {

    /// Default to `true`. Override to disable logging baised off of a `tag` or the `priority`
    public func isLoggable(tag: String?, priority: ForestKit.Priority) -> Bool {
        true
    }
}
