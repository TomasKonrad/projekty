import SwiftUI

@Observable
class ReportUIState {
    var selectedType: ReportType? = nil
    var isLoading = false
    var error: String?
    var isSubmitted = false
}
