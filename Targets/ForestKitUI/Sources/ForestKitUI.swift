import ForestKit
import SwiftUI

public struct ForestKitUI: View {

    @ObservedObject private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        List(viewModel.logs) { data in
            Text(data.log)
        }
        .onAppear {
            viewModel.load()
        }
    }

}

private struct LogData: Identifiable {
    var log: String
    var id: String {
        log
    }
}

private class ViewModel: ObservableObject {

    private let tree: ForestKit.FileOutputTree
    @Published var logs = [LogData]()
    private var logsFromDisk = [LogData]()

    init() {
        if let tree = ForestKit.instance.forest().first(where: { $0 is ForestKit.FileOutputTree }) as? ForestKit.FileOutputTree {
            self.tree = tree
        } else {
            fatalError("Error no \(ForestKit.FileOutputTree.self) is planted")
        }
    }

    func load() {
        do {
            // TODO this is not breaking apart the logs
            let log = try String(contentsOf: tree.fileURL, encoding: .utf8)
            print("WTF:\n\(log)")
            logsFromDisk = log.components(separatedBy: ForestKit.FileOutputTree.logPostFix)
                .filter { !$0.isEmpty }
                .map { LogData(log: $0) }
            logs = logsFromDisk
        } catch {
            fatalError("Error getting log file for: \(tree.fileURL)")
        }
    }

}
