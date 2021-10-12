import Combine
import ForestKit
import Foundation

typealias LogData = ForestKit.FileOutputTree.LogData

class FileOutputTreeViewModel: ObservableObject {

    private let tree: ForestKit.FileOutputTree
    private let jsonDecoder: JSONDecoder
    private var logsFromDisk = [LogData]()

    @Published var logs = [LogData]()
    @Published var search = ""
    @Published var selectedPriorities = Set(ForestKit.Priority.allCases)
    @Published var selectedError: ErrorFilter = .both
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
        selectedError = error
    }

    func isSelected(for sort: SortOrder) -> Bool {
        sort == selectedSort
    }

    func selectedSort(with sort: SortOrder) {
        selectedSort = sort
    }

    func load() {

        func loadSync() {
            do {
                let log = try String(contentsOf: tree.fileURL, encoding: .utf8)
                // Seperate on the end of the JSON object + the new line, it should be unique.
                logsFromDisk = try log.components(separatedBy: "}\n")
                    .filter { !$0.isEmpty }
                    .compactMap {
                        // Need add back in the `}` since the split removed it
                        guard let data = "\($0)}".data(using: .utf8) else { return nil }
                        return try jsonDecoder.decode(LogData.self, from: data)
                    }
                logs = logsFromDisk
            } catch {
                print("\(ForestKit.Priority.error) - Getting log file for: \(tree.fileURL)")
            }
        }

        DispatchQueue.main.async {
            loadSync()
        }
    }
}

private extension Array where Element == LogData {
    func search(with query: String) -> [LogData] {
        if query.isEmpty {
            return self
        } else {
            return filter { log in
                log.message.localizedCaseInsensitiveContains(query) ||
                    log.error?.localizedCaseInsensitiveContains(query) ?? false ||
                    log.priority.rawValue.localizedCaseInsensitiveContains(query)
            }
        }
    }

    func filter(with priorities: Set<ForestKit.Priority>) -> [LogData] {
        filter {
            priorities.contains($0.priority)
        }
    }

    func filter(with error: ErrorFilter) -> [LogData] {
        filter {
            switch error {
            case .no:
                return $0.error == nil
            case .yes:
                return $0.error != nil
            case .both:
                return true
            }
        }
    }

    func sorted(by sort: SortOrder) -> [LogData] {
        switch sort {
        case .acending:
            return sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        case .decending:
            return sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        }
    }
}

/// The filter for showing logs by `LogData.error`. `nil` means show all logs.
enum ErrorFilter: String, CaseIterable {
    case yes = "Errors"
    case no = "No Errors"
    case both = "Show All"
}

/// FIlter to change the sort order of the logs.
enum SortOrder: String, CaseIterable {
    case decending = "Decending Date"
    case acending = "Accending Date"
}
