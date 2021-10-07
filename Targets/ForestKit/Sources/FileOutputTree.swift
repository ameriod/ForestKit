import Foundation

extension ForestKit {

    public class FileOutputTree: Tree {

        private let documents: String
        private let documentsURL: URL
        /// The file URL the logs will be written to
        public let fileURL: URL
        private let encoder: JSONEncoder

        public init(fileName: String = "ForestKitApplication.log", clearOnStart: Bool = true) {
            documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            documentsURL = URL(fileURLWithPath: documents)
            fileURL = documentsURL.appendingPathComponent(fileName)
            encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            if clearOnStart {
                clearAll()
            }
        }

        public func log(priority: ForestKit.Priority, tag: String?, message: String, error: Error?) {

            func writeLog() {
                let errorStr: String?
                if let error = error {
                    errorStr = String(describing: error)
                } else {
                    errorStr = nil
                }
                let log = LogData(date: Date(), priority: priority, tag: tag, message: message, error: errorStr)
                do {
                    let data = try encoder.encode(log)
                    let json = String(decoding: data, as: UTF8.self)
                    try "\(json)\n".append(to: fileURL)
                } catch {
                    print("\(ForestKit.Priority.error) - Adding Log: \(log) to File: \(fileURL) to FileOutputTree")
                }
            }

            if Thread.isMainThread {
                DispatchQueue.main.async {
                    writeLog()
                }
            } else {
                writeLog()
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

private typealias LogData = ForestKit.FileOutputTree.LogData

public extension ForestKit.FileOutputTree {

    /// The `Codable` that converts the logs from `ForestKit.FileOutputTree` to json to store in the file.
    struct LogData: Codable, Identifiable {
        public var date: Date
        public var priority: ForestKit.Priority
        public var tag: String?
        public var message: String
        public var error: String?

        public var id: String {
            "\(date.description) - \(message)"
        }

        enum CodingKeys: String, CodingKey {
            case date
            case priority
            case tag
            case message
            case error
        }
    }
}

extension String {

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
