import SwiftUI

struct LocationDetailView: View {
    let location: RecyclingLocation
    let onDismiss: () -> Void
    let currentUser: AppUser?
    let onReport: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    // Bool — true = potvrzeni, false = zamitnutí
    let onVote: (RecyclingLocation, Bool) -> Void

    @State private var viewModel: LocationDetailViewModel
    @State private var showDeleteConfirmation = false

    init(location: RecyclingLocation,
         onDismiss: @escaping () -> Void,
         currentUser: AppUser? = nil,
         onReport: @escaping () -> Void = {},
         onEdit: @escaping () -> Void = {},
         onDelete: @escaping () -> Void = {},
         onVote: @escaping (RecyclingLocation, Bool) -> Void = { _, _ in },
         viewModel: LocationDetailViewModel = LocationDetailViewModel()) {
        self.location = location
        self.onDismiss = onDismiss
        self.currentUser = currentUser
        self.onReport = onReport
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onVote = onVote
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    imageSection
                    titleSection
                    if !location.types.isEmpty {
                        wasteTypesCard
                            .padding(.top, 8)
                    }
                    if location.category == .collectionYard {
                        if location.isPublic != nil || location.hasFee != nil {
                            availabilityRow
                        }
                        if location.openingHours != nil {
                            openingHoursCard
                        }
                    }
                    if let name = location.operatorName {
                        operatorCard(name)
                    }
                    if location.category == .collectionYard, let phone = location.phone {
                        contactCard(phone)
                    }
                }
                .padding(16)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
            if canVote { votingButtons }
        }
        .onAppear { viewModel.load(for: location) }
        .alert("Chyba", isPresented: Binding(
            get: { viewModel.state.voteError != nil },
            set: { if !$0 { viewModel.state.voteError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.state.voteError ?? "")
        }
        .alert("Smazat sběrné místo?", isPresented: $showDeleteConfirmation) {
            Button("Zrušit", role: .cancel) {}
            Button("Smazat", role: .destructive) { onDelete() }
        } message: {
            Text("Tato akce je nevratná.")
        }
    }

    // MARK: - Header

    // uzivatel muze spravovat lokaci kdyz je pending a pridal ji on, nebo kdyz je moderator
    private var canManage: Bool {
        guard let user = currentUser else { return false }
        return (location.status == .pending && location.addedBy == user.id)
            || user.role == .moderator
    }

    // prihlaseny uzivatel ktery nepridaval tento bin muze hlasovat — moderator vzdy
    // zkontrolujeme take votes mapu aby se zabranilo opakovnemu hlasovani po zavreni sheetu
    private var canVote: Bool {
        guard let user = currentUser,
              location.status == .pending,
              location.votes[user.id] == nil,
              !viewModel.state.hasVoted else { return false }
        return user.role == .moderator || location.addedBy != user.id
    }

    private var header: some View {
        ZStack {
            Text(location.category.label)
                .font(.headline)
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .frame(width: 36, height: 36)
                        .glassEffect(in: Circle())
                }
                .buttonStyle(.plain)
                Spacer()
                if canManage {
                    // vlastnik pending binu nebo moderator — moznosti spravovani
                    Menu {
                        Button { onEdit() } label: {
                            Label("Upravit", systemImage: "pencil")
                        }
                        Button(role: .destructive) { showDeleteConfirmation = true } label: {
                            Label("Smazat", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .frame(width: 36, height: 36)
                            .glassEffect(in: Circle())
                    }
                    .buttonStyle(.plain)
                } else if location.status != .pending {
                    // report je dostupny jen pro schvalene biny
                    Button(action: onReport) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .frame(width: 36, height: 36)
                            .glassEffect(in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Image

    private var imageSection: some View {
        ZStack(alignment: .bottom) {
            if let data = location.imageData, let uiImage = UIImage(data: data) {
                // zobrazeni nahrane fotky
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                imagePlaceholder
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            HStack {
                if location.category == .collectionYard {
                    statusBadge
                }
                Spacer()
                if let distance = viewModel.state.distance {
                    Label(distance, systemImage: "location.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.primary, in: Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: location.category.mapIcon)
                    .font(.system(size: 56))
                    .foregroundStyle(Color(.systemGray3))
            }
    }

    private var statusBadge: some View {
        let label: String
        let color: Color
        if let open = viewModel.state.isOpenNow {
            label = open ? "Otevřeno" : "Zavřeno"
            color = open ? Color.primary : .red
        } else {
            switch location.status {
            case .active:   label = "Otevřeno"; color = Color.primary
            case .pending:  label = "Čeká";     color = .orange
            case .rejected: label = "Zavřeno";  color = .red
            }
        }
        return Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color, in: Capsule())
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // pro sberne dvory zobraz nazev operatora jako hlavni nadpis
            let title = (location.category == .collectionYard ? location.operatorName : nil)
                ?? location.category.detailTitle
            HStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.bold))
                if location.category != .collectionYard {
                    Image(systemName: location.status.icon)
                }
            }
            if let address = viewModel.state.address {
                Label(address, systemImage: "mappin")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Cards

    private var wasteTypesCard: some View {
        DetailCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Odebíraný odpad", systemImage: "arrow.3.trianglepath")
                    .font(.headline)
                FlowLayout(spacing: 8) {
                    ForEach(location.types) { type in
                        Text(type.label)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.primary.opacity(0.12), in: Capsule())
                    }
                }
            }
        }
    }

    // dve male karty vedle sebe — dostupnost a poplatky
    private var availabilityRow: some View {
        HStack(spacing: 12) {
            if let isPublic = location.isPublic {
                DetailCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dostupnost")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(isPublic ? "Veřejné" : "Soukromé")
                            .font(.title3.weight(.bold))
                    }
                }
            }
            if let hasFee = location.hasFee {
                DetailCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Poplatky")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(hasFee ? "Ano" : "Ne")
                            .font(.title3.weight(.bold))
                    }
                }
            }
        }
    }

    private var openingHoursCard: some View {
        DetailCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Provozní doba", systemImage: "clock")
                    .font(.headline)
                VStack(spacing: 8) {
                    ForEach(Array(viewModel.state.schedule.enumerated()), id: \.offset) { _, day in
                        HStack {
                            Text(day.name)
                                .font(.subheadline.weight(day.isToday ? .semibold : .regular))
                                .foregroundStyle(Color(.label))
                            Spacer()
                            Text(day.hours)
                                .font(.subheadline.weight(day.isToday ? .semibold : .regular))
                                .foregroundStyle(
                                    day.isToday ? Color.primary :
                                    day.isClosed ? .red : Color(.label)
                                )
                        }
                    }
                }
            }
        }
    }

    private func operatorCard(_ name: String) -> some View {
        DetailCard {
            VStack(alignment: .leading, spacing: 6) {
                Label("Správce", systemImage: "shield")
                    .font(.headline)
                Text(name)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 28)
            }
        }
    }

    private func contactCard(_ phone: String) -> some View {
        DetailCard {
            VStack(alignment: .leading, spacing: 6) {
                Label("Kontakt", systemImage: "phone")
                    .font(.headline)
                Text(phone)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 28)
            }
        }
    }

    // MARK: - Voting buttons

    private var votingButtons: some View {
        VStack(spacing: 10) {
            Text("Sběrné místo čeká na vyřízení. Potvrďte prosím, jestli jsou informace správné.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                voteButton(label: "Potvrdit", icon: "checkmark", color: .green, confirm: true)
                voteButton(label: "Zamítnout", icon: "xmark", color: .red, confirm: false)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func voteButton(label: String, icon: String, color: Color, confirm: Bool) -> some View {
        Button {
            guard let user = currentUser else { return }
            Task {
                if let updated = await viewModel.vote(confirm: confirm, on: location, as: user) {
                    onVote(updated, confirm)
                }
            }
        } label: {
            Group {
                if viewModel.state.isVoting {
                    ProgressView().tint(.white)
                } else {
                    Label(label, systemImage: icon)
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.state.isVoting)
    }
}

// MARK: - Preview

#Preview("Kontejner") {
    let vm = LocationDetailViewModel(locationService: MockLocationManager(), geocodingService: MockGeocodingManager())
    vm.state.address = "Střední, Brno-Královo Pole"
    vm.state.distance = "100m"
    return LocationDetailView(location: .getSample(), onDismiss: {}, viewModel: vm)
        .presentationBackground(Color(.systemGroupedBackground))
}

#Preview("Sběrný dvůr") {
    let vm = LocationDetailViewModel(locationService: MockLocationManager(), geocodingService: MockGeocodingManager())
    vm.state.address = "Vídeňská, Brno-Komín"
    vm.state.distance = "1.4km"
    return LocationDetailView(location: .getSampleYard(), onDismiss: {}, viewModel: vm)
        .presentationBackground(Color(.systemGroupedBackground))
}
