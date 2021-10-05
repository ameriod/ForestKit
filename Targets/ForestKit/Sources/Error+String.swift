import Foundation

extension Optional where Wrapped: Error {

    func forestMessage(separator: String = "\n") -> String {
        if let error = self {
            return "\(separator)Error: \(error)"
        }
        return ""
    }
}
