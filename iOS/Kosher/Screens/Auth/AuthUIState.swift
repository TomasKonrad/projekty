import SwiftUI

@Observable
class AuthViewState {
    var isLoading = false
    var error: String?
    var currentUser: AppUser?
}
