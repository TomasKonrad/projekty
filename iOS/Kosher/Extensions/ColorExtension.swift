import SwiftUI

//tady jsou definované všechny custom barvy, které jsme si definovali v návrhu designu

extension Color {
    // hlavní barvy
    static let primary = Color(red: 16/255, green: 165/255, blue: 83/255)
    static let tertiary = Color(red: 165/255, green: 255/255, blue: 206/255)
    static let lightGray = Color(red: 221/255, green: 221/255, blue: 232/255)

    // statusy
    static let statusActive = Color(red: 169/255, green: 255/255, blue: 182/255)
    static let statusPending = Color(red: 211/255, green: 211/255, blue: 211/255)
    static let statusRejected = Color(red: 255/255, green: 175/255, blue: 175/255)
    static let statusText = Color.black
}
