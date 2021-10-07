import ForestKitView
import SwiftUI

@main
struct AppMainView: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .navigationBarTitle(Text("ForestKit Sample"), displayMode: .inline)
            }
        }
    }
}

struct ContentView: View {
    @State var message: String = ""
    @State var errorMessage: String = ""

    var body: some View {
        VStack {
            Group {
                TextField("Log Message", text: $message)
                TextField("Error message, empty for no error", text: $errorMessage)
                Button("Log \(ForestKitLogging.Priority.default.rawValue)") {
                    Forest.log(error, message)
                }
                Button("Log \(ForestKitLogging.Priority.info.rawValue)") {
                    Forest.i(error, message)
                }
                Button("Log \(ForestKitLogging.Priority.debug.rawValue)") {
                    Forest.d(error, message)
                }
                Button("Log \(ForestKitLogging.Priority.error.rawValue)") {
                    Forest.e(error, message)
                }
                Button("Log \(ForestKitLogging.Priority.fault.rawValue)") {
                    Forest.f(error, message)
                }
                Button("Log \(ForestKitLogging.Priority.wtf.rawValue)") {
                    Forest.wtf(error, message)
                }
            }
            Spacer()
            Button(action: { }, label: {
                NavigationLink(destination: fileTreeOutputView()) {
                    Text("FileOutputTree View")
                }
            })
        }
        .padding()
    }

    var error: Error? {
        if errorMessage.isEmpty {
            return nil
        }
        return TestError.runtimeError(errorMessage)
    }

    func fileTreeOutputView() -> some View {
        ForestKitView.LogViewer()
            .navigationBarTitle(Text("FileOutputTree"), displayMode: .inline)
    }
}

enum TestError: Error {
    case runtimeError(String)
}
