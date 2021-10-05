import Foundation
import os

extension ForestKit {

    /// `Tree` powered by `OSLog`
    public class OSLogTree: Tree {

        private let log: OSLog

        public init(with log: OSLog) {
            self.log = log
        }

        public convenience init(subsystem: String, category: String) {
            self.init(with: OSLog(subsystem: subsystem, category: category))
        }

        public convenience init() {
            self.init(with: .default)
        }

        public func log(priority: ForestKit.Priority, tag: String?, message: String, error: Error?) {
            if let tag = tag {
                os_log("%s - %s", log: log, type: priority.osLog, tag, "\(message)\(error.forestMessage())")
            } else {
                os_log("%s", log: log, type: priority.osLog, "\(message)\(error.forestMessage())")
            }
        }

    }
}

private extension ForestKit.Priority {

    var osLog: OSLogType {
        switch self {
        case .default:
            return .default
        case .info:
            return .info
        case .debug:
            return .debug
        case .error:
            return .error
        case .fault, .wtf:
            return .fault
        }
    }
}
