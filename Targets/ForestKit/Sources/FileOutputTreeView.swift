import Combine
import SwiftUI

public extension ForestKit {

    struct FileOutputTreeView: View {

        @ObservedObject private var viewModel = ViewModel()
        @State private var showFilters = false

        public init() { }

        public var body: some View {
            VStack {
                HStack {
                    TextField("Search", text: $viewModel.search)
                        .frame(maxWidth: .infinity)
                    Button("Filters") {
                        showFilters = true
                    }
                }
                .padding()
                List(viewModel.logs) { data in
                    LogView(data: data)
                        .onTapGesture {
                            // Copy the log to share it.
                            UIPasteboard.general.string = "\(data)"
                        }
                }
            }
            .sheet(isPresented: $showFilters) {
                LogFilterView(viewModel: viewModel, showFilters: $showFilters)
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
            Text(data.priority.rawValue)
                .foregroundColor(data.priority.color)
            Text(data.date.description)
            Text(data.message)
            if let error = data.error {
                Text(error.description)
            }
        }
    }
}

private struct LogFilterView: View {

    @ObservedObject var viewModel: ViewModel
    @Binding var showFilters: Bool

    var body: some View {
        List {
            Section(header: Text("Priority")) {
                ForEach(ForestKit.Priority.allCases, id: \.self) { priority in
                    Text(priority.rawValue)
                        .foregroundColor(selectedColor(viewModel.isSelected(for: priority)))
                        .onTapGesture {
                            viewModel.prioritySelected(with: priority)
                        }
                }
            }
            Section(header: Text("Errors")) {
            }
            Section(header: Text("Date")) {

            }
        }
        .textCase(nil)
        Button("Close") {
            showFilters = false
        }
    }

    func selectedColor(_ selected: Bool) -> Color? {
        if selected {
            return .accentColor
        }
        return nil
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
    @Published var search = ""
    @Published var selectedPriorities: Set<ForestKit.Priority> = []

    private var disposables = Set<AnyCancellable>()

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

        Publishers.CombineLatest($search, $selectedPriorities)
            .map { query, priorities in
                self.logsFromDisk.search(with: query).filter(with: priorities)
            }
            .sink { searchedLogs in
                self.logs = searchedLogs
            }
            .store(in: &disposables)
    }

    func isSelected(for priority: ForestKit.Priority) -> Bool {
        selectedPriorities.contains(priority)
    }

    func prioritySelected(with priority: ForestKit.Priority) {
        if isSelected(for: priority) {
            selectedPriorities.remove(priority)
        } else {
            selectedPriorities.insert(priority)
        }
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

private enum ErrorFilter: String, CaseIterable {
    case errors = "Errors"
    case no_errors = "No Errors"
    case all = "All"
}

private enum SortOrder: String, CaseIterable {
    case decending = "Decending Date"
    case acending = "Accending Date"
}

private extension Array where Element == FileLogData {
    func search(with query: String) -> [FileLogData] {
        if query.isEmpty {
            return self
        } else {
            return filter { log in
                log.message.localizedCaseInsensitiveContains(query) ||
                    log.error?.localizedCaseInsensitiveContains(query) == true ||
                    log.priority.rawValue.localizedCaseInsensitiveContains(query)
            }
        }
    }

    func filter(with priorities: Set<ForestKit.Priority>) -> [FileLogData] {
        if priorities.isEmpty {
            return self
        }
        return filter {
            priorities.contains($0.priority)
        }
    }
}
