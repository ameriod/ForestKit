import Combine
import ForestKit
import SwiftUI

public extension ForestKitView {

    /// The UI to view logs producted by the `ForestKit.FileOutputTree`.
    struct LogViewer: View {

        @ObservedObject private var viewModel = FileOutputTreeViewModel()
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

    let data: LogData

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

    @ObservedObject var viewModel: FileOutputTreeViewModel
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
            Section(header: Text("Sort")) {
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
