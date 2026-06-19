import SwiftUI

struct DetailCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}
