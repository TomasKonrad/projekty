import SwiftUI

struct UserRowView: View {
    let user: AppUser

    var body: some View {
        HStack(spacing: 12) {

            AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.system(size: 40))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            Text(user.displayName)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            if user.isBanned {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color.statusRejected)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        UserRowView(user: .getSample())
        UserRowView(user: .getSampleModerator())
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
