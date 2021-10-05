import Foundation

extension ForestKit {

    /// `Tree` that just uses `print`
    public class PrintTree: Tree {

        public init() { }

        public func log(priority: ForestKit.Priority, tag: String?, message: String, error: Error?) {
            print(logString(priority: priority, tag: tag, message: message, error: error))
        }

        func logString(priority: ForestKit.Priority, tag: String?, message: String, error: Error?) -> String {
            let date = Date()
            if let tag = tag {
                return "\(date) - \(priority) - \(tag) - \(message)\(error.forestMessage)"
            } else {
                return "\(date) - \(priority) - \(message)\(error.forestMessage)"
            }
        }
    }
}
