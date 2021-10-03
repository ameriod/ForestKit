import Foundation

extension Optional where Wrapped: Error {

    var forestMessage: String {
        if let error = self {
            return "/nError: \(error)"
        }
        return ""
    }
}
