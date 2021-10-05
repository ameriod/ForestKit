import SwiftUI

public extension ForestKit {

    struct FileOutputTreeView: View {

        @ObservedObject private var viewModel = ViewModel()

        public init() { }

        public var body: some View {
            List(viewModel.logs) { data in
                LogView(data: data)
                    .onTapGesture {
                        // Copy the log to share it.
                        UIPasteboard.general.string = "\(data)"
                    }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }
}

private struct LogView: View {

    let data: FileLogData

    var body: some View {
        VStack(alignment: .leading) {
            Text(data.priority.description)
                .foregroundColor(data.priority.color)
            Text(data.date.description)
            Text(data.message)
            if let error = data.error {
                Text(error.description)
            }
        }
    }
}

extension ForestKit.Priority {

    var color: Color {
        switch self {
        case .debug, .default, .info:
            return .gray
        case .error, .fault, .wtf:
            return .red
        }
    }
}

private class ViewModel: ObservableObject {

    private let tree: ForestKit.FileOutputTree
    @Published var logs = [FileLogData]()
    private var logsFromDisk = [FileLogData]()
    private let jsonDecoder: JSONDecoder

    init() {
        if let tree = ForestKit.instance.forest().first(where: { $0 is ForestKit.FileOutputTree }) as? ForestKit.FileOutputTree {
            self.tree = tree
        } else {
            print("\(ForestKit.Priority.error) - No \(ForestKit.FileOutputTree.self) is planted")
            // Create a dummy tree since the logging library should not crash the app.
            tree = ForestKit.FileOutputTree()
        }
        jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
    }

    func load() {
        DispatchQueue.main.async {
            self.loadSync()
        }
    }

    private func loadSync() {
        do {
            let log = try String(contentsOf: tree.fileURL, encoding: .utf8)
            // Seperate on the end of the JSON object + the new line, it should be unique.
            logsFromDisk = try log.components(separatedBy: "}\n")
                .filter { !$0.isEmpty }
                .compactMap {
                    // Need add back in the `}` since the split removed it
                    guard let data = "\($0)}".data(using: .utf8) else { return nil }
                    return try jsonDecoder.decode(FileLogData.self, from: data)
                }
            logs = logsFromDisk
        } catch {
            print("\(ForestKit.Priority.error) - Getting log file for: \(tree.fileURL)")
        }
    }
}
