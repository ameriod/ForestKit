import Foundation

/// `Tree` that just uses `print`
public class PrintDebugTree: Tree {

    public init() { }

    public func log(priority: ForestKit.Priority, tag: String?, message: String, error: Error?) {
        if let tag = tag {
            print("\(priority) - \(tag) - \(message)\(error.forestMessage)")
        } else {
            print("\(priority) - \(message)\(error.forestMessage)")
        }
    }
}