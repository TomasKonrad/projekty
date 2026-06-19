import SwiftUI

// sjednoceny view pro profil — vlastni profil i profil jineho uzivatele
struct UserProfileView: View {
    enum Mode {
        // vlastni profil — zobrazuje tlacitko odhlaseni v toolbaru
        case ownProfile(onSignOut: () -> Void)
        // profil jineho uzivatele — zobrazuje tlacitka ban/unban
        case otherUser(currentUserId: String?, onBan: (String) async -> Void, onUnban: () async -> Void)
    }

    let user: AppUser
    let contributions: [RecyclingLocation]
    var isLoadingContributions: Bool = false
    let coordinator: AppCoordinator
    let mode: Mode

    @State private var showBanDialog = false
    @State private var banReason = ""
    @State private var showAdmin = false
    @State private var showSignOutDialog = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // avatar a jmeno
                VStack(spacing: 8) {
                    AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 100))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())

                    Text(user.displayName)
                        .font(.title2.weight(.semibold))
                }
                .padding(.top)

                // statistiky — pocet prispevku a odevzdanych hlasu
                VStack(alignment: .leading, spacing: 12) {
                    Text("Statistiky")
                        .font(.headline)
                        .padding(.horizontal)
                    HStack(spacing: 16) {
                        StatCardView(title: "Přidáno míst",     value: "\(contributions.count)")
                        StatCardView(title: "Hlasů odevzdáno",  value: "\(user.votesGiven)")
                    }
                    .padding(.horizontal)
                }

                // odkaz na administraci — jen pro moderatory na vlastnim profilu
                if case .ownProfile = mode, user.role == .moderator {
                    Button { showAdmin = true } label: {
                        HStack {
                            Label("Administrace", systemImage: "eye")
                                .font(.body.weight(.medium))
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(.label))
                        }
                        .padding()
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .fullScreenCover(isPresented: $showAdmin) { AdminView() }
                }

                // prispevky — titulek se lisi podle kontextu
                VStack(alignment: .leading, spacing: 12) {
                    Text(contributionsSectionTitle)
                        .font(.headline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if isLoadingContributions {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 32)
                    } else if contributions.isEmpty {
                        Text("Zatím žádné příspěvky.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 32)
                    } else {
                        ForEach(contributions) { location in
                            Button {
                                coordinator.pendingMapLocation = location
                            } label: {
                                ContributionRowView(location: location)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }
                }

            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        // tlacitka v toolbaru — odhlaseni pro vlastni profil, ban/unban pro profil jineho uzivatele
        .toolbar {
            if case .ownProfile = mode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSignOutDialog = true } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    .foregroundStyle(.red)
                }
            }
            if case .otherUser(let currentUserId, _, _) = mode, user.id != currentUserId {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if user.isBanned { Task { await performUnban() } }
                        else { showBanDialog = true }
                    } label: {
                        Text(user.isBanned ? "Odblokovat" : "Zablokovat")
                            .fontWeight(.medium)
                            .foregroundStyle(user.isBanned ? .green : .red)
                    }
                }
            }
        }
        .alert("Odhlásit se?", isPresented: $showSignOutDialog) {
            Button("Zrušit", role: .cancel) {}
            Button("Odhlásit se", role: .destructive) {
                if case .ownProfile(let onSignOut) = mode { onSignOut() }
            }
        }
        .alert("Zablokovat uživatele?", isPresented: $showBanDialog) {
            TextField("Zadejte důvod", text: $banReason)
            Button("Zrušit", role: .cancel) { banReason = "" }
            Button("Potvrdit", role: .destructive) {
                Task { await performBan() }
            }
        } message: {
            Text("Uživatel se již nebude moci přihlásit.")
        }
    }

    private var contributionsSectionTitle: String {
        if case .ownProfile = mode { return "Moje příspěvky" }
        return "Příspěvky"
    }

    private func performBan() async {
        guard case .otherUser(_, let onBan, _) = mode else { return }
        await onBan(banReason)
        banReason = ""
    }

    private func performUnban() async {
        guard case .otherUser(_, _, let onUnban) = mode else { return }
        await onUnban()
    }
}

#Preview("Vlastní profil") {
    NavigationStack {
        UserProfileView(
            user: .getSample(),
            contributions: [.getSample(), .getSampleYard()],
            coordinator: AppCoordinator(),
            mode: .ownProfile(onSignOut: {})
        )
    }
}

#Preview("Profil jiného uživatele") {
    NavigationStack {
        UserProfileView(
            user: .getSample(),
            contributions: [.getSample()],
            coordinator: AppCoordinator(),
            mode: .otherUser(currentUserId: "other-id", onBan: { _ in }, onUnban: {})
        )
    }
}
