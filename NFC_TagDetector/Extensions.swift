
import Foundation

extension DateFormatter {
    func apply(_ block: (DateFormatter) -> Void) -> DateFormatter {
        block(self)
        return self
    }
}
