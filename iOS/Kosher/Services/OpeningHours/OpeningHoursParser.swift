import Foundation

final class OpeningHoursParser: OpeningHoursManaging {
    // parsovani OSM formatu "Mo-Fr 08:00-16:00; Sa 09:00-15:00; Su off"
    func parse(_ raw: String) -> [DaySchedule] {
        let osmDays    = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
        let czechNames = ["Pondělí", "Úterý", "Středa", "Čtvrtek", "Pátek", "Sobota", "Neděle"]
        // Calendar weekday: 1=Ne, 2=Po, ..., 7=So → prevedeme na OSM index Mo=0..Su=6
        let calWeekday = Calendar.current.component(.weekday, from: Date())
        let todayOsm   = [6, 0, 1, 2, 3, 4, 5][calWeekday - 1]

        var schedule = [Int: String]()
        for segment in raw.components(separatedBy: "; ") {
            let s = segment.trimmingCharacters(in: .whitespaces)
            guard let spaceIdx = s.firstIndex(of: " ") else { continue }
            let dayPart   = String(s[s.startIndex..<spaceIdx])
            let hoursPart = String(s[s.index(after: spaceIdx)...])
            if dayPart.contains("-") {
                let r = dayPart.components(separatedBy: "-")
                if r.count == 2,
                   let start = osmDays.firstIndex(of: r[0]),
                   let end   = osmDays.firstIndex(of: r[1]) {
                    for i in start...end { schedule[i] = hoursPart }
                }
            } else if let idx = osmDays.firstIndex(of: dayPart) {
                schedule[idx] = hoursPart
            }
        }

        return (0..<7).map { i in
            let rawH    = schedule[i] ?? "off"
            let closed  = rawH == "off"
            let display = closed ? "Zavřeno" : rawH.replacingOccurrences(of: "-", with: " – ")
            return DaySchedule(name: czechNames[i], hours: display, rawHours: rawH,
                               isToday: i == todayOsm, isClosed: closed)
        }
    }

    // overi podle aktualniho casu, zda je misto otevreno
    func isOpenNow(_ raw: String) -> Bool {
        let days = parse(raw)
        guard let today = days.first(where: { $0.isToday }), !today.isClosed else { return false }
        let parts = today.rawHours.components(separatedBy: "-")
        guard parts.count == 2 else { return false }
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        guard let openTime  = fmt.date(from: parts[0]),
              let closeTime = fmt.date(from: parts[1]) else { return false }
        func toMinutes(_ d: Date) -> Int {
            let c = Calendar.current.dateComponents([.hour, .minute], from: d)
            return (c.hour ?? 0) * 60 + (c.minute ?? 0)
        }
        let now = toMinutes(Date())
        return now >= toMinutes(openTime) && now < toMinutes(closeTime)
    }
}
