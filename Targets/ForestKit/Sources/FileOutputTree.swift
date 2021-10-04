import Foundation

extension ForestKit {

    public class FileOutputTree: Tree {

        private let documents: String
        private let documentsURL: URL
        /// The file URL the logs will be written to
        public let fileURL: URL
        /// The start of a log in the file
        public static let logStartPrefix: String = "[!@$#%]"

        public init(fileName: String = "ForestKitApplication.log", clearOnStart: Bool = true) {
            documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            documentsURL = URL(fileURLWithPath: documents)
            fileURL = documentsURL.appendingPathComponent(fileName)
            if clearOnStart {
                clearAll()
            }
        }

        public func log(priority: ForestKit.Priority, tag: String?, message: String, error: Error?) {
            let log: String
            let date = Date()
            if let tag = tag {
                log = "\(FileOutputTree.logStartPrefix)\(date) - \(priority) - \(tag) - \(message)\(error.forestMessage)"
            } else {
                log = "\(FileOutputTree.logStartPrefix)\(date) - \(priority) - \(message)\(error.forestMessage)"
            }

            do {
                try log.appendLine(to: fileURL)
            } catch {
                print("\(ForestKit.Priority.error) - Writing FileOutputTree to \(fileURL) failed")
            }
        }

        func clearAll() {
            do {
                try "".write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                print("\(ForestKit.Priority.error) - Clearing FileOutputTree \(fileURL) failed")
            }
        }
    }
}

extension String {

    func appendLine(to url: URL) throws {
        try appending("\n").append(to: url)
    }

    func append(to url: URL) throws {
        let data = self.data(using: String.Encoding.utf8)
        try data?.append(to: url)
    }
}

extension Data {

    func append(to url: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: url) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: url)
        }
    }
}
