import SwiftUI

@Observable
class LocationDetailViewState {
    var address: String? = nil
    var distance: String? = nil
    var isOpenNow: Bool? = nil
    var schedule: [DaySchedule] = []
    // stav hlasovani
    var isVoting: Bool = false
    var hasVoted: Bool = false
    var voteError: String? = nil
}
