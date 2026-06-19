import SwiftUI

struct FilterSheetView: View {
    var viewModel: MapViewModel
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    filterSection("Sběrné místo",
                                  onSelectAll: { viewModel.selectAllCategories() },
                                  onClear:     { viewModel.clearCategories() }) {
                        FlowLayout(spacing: 8) {
                            ForEach(LocationCategory.allCases) { cat in
                                FilterChip(label: cat.chipLabel,
                                           isSelected: viewModel.state.selectedCategories.contains(cat)) {
                                    viewModel.toggleCategory(cat)
                                }
                            }
                        }
                    }
                    filterSection("Typ odpadu",
                                  onSelectAll: { viewModel.selectAllWasteTypes() },
                                  onClear:     { viewModel.clearWasteTypes() }) {
                        FlowLayout(spacing: 8) {
                            ForEach(WasteType.allCases) { type in
                                FilterChip(label: type.label,
                                           isSelected: viewModel.state.selectedWasteTypes.contains(type)) {
                                    viewModel.toggleWasteType(type)
                                }
                            }
                        }
                    }
                    filterSection("Dostupnost",
                                  onSelectAll: { viewModel.selectAllStatuses() },
                                  onClear:     { viewModel.clearStatuses() }) {
                        FlowLayout(spacing: 8) {
                            ForEach([LocationStatus.active, .pending], id: \.self) { status in
                                FilterChip(label: status.label,
                                           isSelected: viewModel.state.selectedStatuses.contains(status)) {
                                    viewModel.toggleStatus(status)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Filtry").font(.headline)
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
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Section helper

    private func filterSection<C: View>(
        _ title: String,
        onSelectAll: @escaping () -> Void,
        onClear: @escaping () -> Void,
        @ViewBuilder content: () -> C
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                // tlacitka pro rychlou selekci — vybrat vse nebo zrusit vse
                HStack(spacing: 4) {
                    Button("Vše", action: onSelectAll)
                    Text("·").foregroundStyle(.tertiary)
                    Button("Žádné", action: onClear)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }
            content()
        }
    }
}

// MARK: - Chip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : Color(.label))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primary : Color(.systemBackground), in: Capsule())
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Flow layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var totalH: CGFloat = 0
        var rowW: CGFloat = 0
        var rowH: CGFloat = 0

        for (i, sub) in subviews.enumerated() {
            let size = sub.sizeThatFits(.unspecified)
            if i > 0 && rowW + spacing + size.width > maxW {
                totalH += rowH + spacing
                rowW = 0; rowH = 0
            }
            rowW += (rowW > 0 ? spacing : 0) + size.width
            rowH = max(rowH, size.height)
        }
        return CGSize(width: maxW, height: totalH + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var rowH: CGFloat = 0

        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                y += rowH + spacing
                x = bounds.minX; rowH = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowH = max(rowH, size.height)
        }
    }
}

// MARK: - LocationCategory short label for chips

private extension LocationCategory {
    // kratsi nazev pro chip v filtru
    var chipLabel: String {
        switch self {
        case .wasteBasket:    "Koš"
        case .recyclingSpot:  "Kontejner"
        case .collectionYard: "Sběrný dvůr"
        }
    }
}
