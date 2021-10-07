import Combine
import ForestKit
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
                ForEach(ErrorFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                        .foregroundColor(selectedColor(viewModel.isSelected(for: filter)))
                        .onTapGesture {
                            viewModel.errorFilterSelected(with: filter)
                        }
                }
            }
            Section(header: Text("Date")) {
                ForEach(SortOrder.allCases, id: \.self) { sort in
                    Text(sort.rawValue)
                        .foregroundColor(selectedColor(viewModel.isSelected(for: sort)))
                        .onTapGesture {
                            viewModel.selectedSort(with: sort)
                        }
                }
            }
        }
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

private enum ErrorFilter: String, CaseIterable {
    case yes = "Errors"
    case no = "No Errors"
}

private enum SortOrder: String, CaseIterable {
    case decending = "Decending Date"
    case acending = "Accending Date"
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
    private let jsonDecoder: JSONDecoder
    private var logsFromDisk = [FileLogData]()

    @Published var logs = [FileLogData]()
    @Published var search = ""
    @Published var selectedPriorities = Set(ForestKit.Priority.allCases)
    @Published var selectedError: ErrorFilter?
    @Published var selectedSort: SortOrder = .decending
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

        Publishers.CombineLatest4($search, $selectedPriorities, $selectedError, $selectedSort)
            .map { [unowned self] query, priorities, error, sort in
                self.logsFromDisk.search(with: query)
                    .filter(with: priorities)
                    .filter(with: error)
                    .sorted(by: sort)
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

    func isSelected(for error: ErrorFilter) -> Bool {
        error == selectedError
    }

    func errorFilterSelected(with error: ErrorFilter) {
        if error == selectedError {
            selectedError = nil
        } else {
            selectedError = error
        }
    }

    func isSelected(for sort: SortOrder) -> Bool {
        sort == selectedSort
    }

    func selectedSort(with sort: SortOrder) {
        selectedSort = sort
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
        filter {
            priorities.contains($0.priority)
        }
    }

    func filter(with error: ErrorFilter?) -> [FileLogData] {
        filter {
            switch error {
            case .no:
                return $0.error == nil
            case .yes:
                return $0.error != nil
            default:
                return true
            }
        }
    }

    func sorted(by sort: SortOrder) -> [FileLogData] {
        switch sort {
        case .acending:
            return sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        case .decending:
            return sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        }
    }
}
