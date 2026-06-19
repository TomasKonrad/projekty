import SwiftUI

@Observable
class ProfileViewState {
    var user: AppUser?
    var contributions: [RecyclingLocation] = []
    var isLoading = false
    var error: String?
}
