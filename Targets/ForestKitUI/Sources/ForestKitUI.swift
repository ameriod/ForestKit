import ForestKit
import SwiftUI

public struct ForestKitUI: View {

    @ObservedObject private var viewModel = ViewModel()

    public init() { }

    public var body: some View {
        List(viewModel.logs) { data in
            Text(data.log)
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

    @Published var logs: [LogData]
    private let logsFromDisk: [LogData]

    init() {
        guard let tree = ForestKit.instance.forest().first(where: { $0 is ForestKit.FileOutputTree }) as? ForestKit.FileOutputTree else {
            fatalError("Error no \(ForestKit.FileOutputTree.self) is planted")
        }
        do {
            // TODO this is not breaking apart the logs
            let log = try String(contentsOf: tree.fileURL, encoding: .utf8)
            print(log)
            logsFromDisk = log.components(separatedBy: ForestKit.FileOutputTree.logStartPrefix)
                .filter { !$0.isEmpty }
                .map { LogData(log: $0) }
            logs = logsFromDisk
        } catch {
            fatalError("Error getting log file for: \(tree.fileURL)")
        }
    }

}
