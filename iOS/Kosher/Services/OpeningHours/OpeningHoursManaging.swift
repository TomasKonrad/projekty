import Foundation

struct DaySchedule {
    let name: String
    let hours: String
    let rawHours: String
    let isToday: Bool
    let isClosed: Bool
}

protocol OpeningHoursManaging {
    func parse(_ raw: String) -> [DaySchedule]
    func isOpenNow(_ raw: String) -> Bool
}
