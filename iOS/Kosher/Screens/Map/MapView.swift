import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel: MapViewModel
    @State private var isFilterPresented: Bool = false
    @State private var isAddingLocation: Bool = false
    // souradnice pro novou lokaci — nastaveno po potvrzeni pickeru, spusti AddBinView
    @State private var addBinCoordinate: CLLocationCoordinate2D? = nil
    // lokace ktera se prave upravuje — spusti AddBinView v rezimu upravy
    @State private var editingLocation: RecyclingLocation? = nil
    @Environment(\.scenePhase) private var scenePhase
    // callbacky pro otevreni profilu a skeneru z ContentView
    var onShowProfile: () -> Void = {}
    var onShowScanner: () -> Void = {}

    // UI stavy pro report
    @State private var isReportPresented = false
    @State private var reportingLocation: RecyclingLocation? = nil
    @State private var toastMessage: String? = nil

    init(viewModel: MapViewModel,
         onShowProfile: @escaping () -> Void = {},
         onShowScanner: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onShowProfile = onShowProfile
        self.onShowScanner = onShowScanner
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack {
            map.ignoresSafeArea()
        }
        .toast(message: $toastMessage)
        .overlay(alignment: .top) {
            VStack(spacing: 8) {
                if case .loading = viewModel.state.loadingState {
                    ProgressView()
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                }
                if viewModel.state.isZoomedOut {
                    Text("Přibliž mapu pro zobrazení kontejnerů")
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .padding(.top, 60)
            .animation(.easeInOut(duration: 0.2), value: viewModel.state.isZoomedOut)
        }
        .overlay(alignment: .bottomLeading) { profileButton }
        .overlay(alignment: .bottomTrailing) { bottomButtons }
        .overlay(alignment: .top) { proximityBanner }
        .overlay(alignment: .center) {
            if isAddingLocation {
                Image(systemName: "mappin")
                    .font(.system(size: 44, weight: .regular))
                    .foregroundStyle(.red)
                    .offset(y: -22)
                    .allowsHitTesting(false)
            }
        }
        .task { await viewModel.load() }
        .alert("Chyba", isPresented: Binding(
            get: { viewModel.state.error != nil },
            set: { if !$0 { viewModel.state.error = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.state.error ?? "")
        }
        .onChange(of: scenePhase) { _, newPhase in
            // navrat do popredi — okamzity refresh aby smazane biny zmizely
            if newPhase == .active { viewModel.refresh() }
        }
        .sheet(isPresented: $isFilterPresented) {
            FilterSheetView(viewModel: viewModel) { isFilterPresented = false }
                .presentationDetents([.medium, .large])
                .presentationBackground(Color(.systemGroupedBackground))
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.state.selectedLocation) { location in
            locationDetail(location)
        }
        .sheet(isPresented: $isAddingLocation) {
            AddLocationSheetView(
                coordinate: viewModel.state.mapCenter,
                onContinue: { coord in
                    // zavreni pickeru a otevreni formulare pro pridani lokace
                    isAddingLocation = false
                    addBinCoordinate = coord
                }
            )
            .presentationDetents([.height(300)])
            .presentationBackground(Color(.systemGroupedBackground))
            .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
            .presentationDragIndicator(.visible)
        }
        // sheet report
        .sheet(item: $reportingLocation) { location in
            ReportView(
                location: location,
                reporterId: viewModel.currentUser?.id ?? "",
                onDismiss: { reportingLocation = nil }
            )
        }
        .fullScreenCover(isPresented: Binding(
            get: { addBinCoordinate != nil },
            set: { if !$0 { addBinCoordinate = nil } }
        )) {
            if let coord = addBinCoordinate {
                NavigationStack {
                    AddBinView(viewModel: AddBinViewModel(coordinate: coord),
                               onSaved: { _ in toastMessage = "Sběrné místo bylo přidáno" })
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { editingLocation != nil },
            set: { if !$0 { editingLocation = nil } }
        )) {
            if let location = editingLocation {
                NavigationStack {
                    AddBinView(
                        viewModel: AddBinViewModel(existingLocation: location),
                        onSaved: { updated in
                            viewModel.replaceLocation(updated)
                            toastMessage = "Změny byly uloženy"
                        }
                    )
                }
            }
        }
    }

    // MARK: - Map

    private var map: some View {
        ClusteredMapView(
            initialRegion: viewModel.state.initialRegion,
            targetCenter: viewModel.state.targetCenter,
            navigateCenter: viewModel.state.navigateCenter,
            navigateVersion: viewModel.state.navigateVersion,
            locations: viewModel.state.filteredLocations,
            onSelect: { location in viewModel.select(location) },
            onCameraIdle: viewModel.onCameraIdle
        )
    }

    // MARK: - Bottom buttons

    // tlacitko profilu — vlevo dole, skryto v rezimu pridavani
    private var profileButton: some View {
        mapButton(icon: "person.circle") { onShowProfile() }
            .padding(.leading, 16)
            .padding(.bottom, 20)
            .opacity(isAddingLocation ? 0 : 1)
            .animation(.easeInOut(duration: 0.15), value: isAddingLocation)
    }

    // tlacitka vpravo dole — vertikalni sloupec
    private var bottomButtons: some View {
        VStack(spacing: 12) {
            if isAddingLocation {
                // v rezimu pridavani jen tlacitko zavrit
                mapButton(icon: "xmark") { isAddingLocation = false }
            } else {
                // neprihlaseny uzivatel — tlacitka jsou vzdy viditelna, presmeruji na profil pro prihlaseni
                mapButton(icon: "plus") {
                    if viewModel.isLoggedIn { isAddingLocation = true }
                    else { onShowProfile() }
                }
                mapButton(icon: "slider.horizontal.3") { isFilterPresented = true }
                mapButton(icon: "location") { viewModel.panToUserLocation() }
                mapButton(icon: "camera") {
                    if viewModel.isLoggedIn { onShowScanner() }
                    else { onShowProfile() }
                }
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 20)
        .animation(.easeInOut(duration: 0.15), value: isAddingLocation)
    }

    private func mapButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(.label))
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pin overlay

    // MARK: - Proximity banner

    // banner s cekajicim binem — zobrazi se kdyz je uzivatel do 300m od neschvaleneho kontejneru
    @ViewBuilder
    private var proximityBanner: some View {
        if let bin = viewModel.state.nearbyPendingBin, viewModel.state.selectedLocation == nil {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 14))
                        .padding(.top, 1)
                    Text("Jsi poblíž nepotvrzeného \(bin.category.proximityLabel), potvrď prosím jestli se nachází v okolí.")
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Button { viewModel.dismissProximityBanner() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color(.label))
                            .padding(6)
                            .background(Color(.systemGray5), in: Circle())
                    }
                }
                Button { viewModel.navigateTo(bin) } label: {
                    Text("Hlasovat")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.orange, in: Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)
      
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: bin.id)
        }
    }

    // MARK: - Location detail sheet

    private func locationDetail(_ location: RecyclingLocation) -> some View {
        LocationDetailView(
            location: location,
            onDismiss: { viewModel.select(nil) },
            currentUser: viewModel.currentUser,
            onReport: {
                // pouze přihlášený uživatel může reportovat
                if viewModel.currentUser != nil {
                    viewModel.select(nil)
                    reportingLocation = location
                } else {
                    viewModel.select(nil)
                    onShowProfile()
                }
            },
            onEdit: {
                viewModel.select(nil)
                editingLocation = location
            },
            onDelete: {
                viewModel.deleteLocation(location)
                toastMessage = "Sběrné místo bylo smazáno"
            },
            onVote: { updated, confirmed in
                viewModel.replaceLocation(updated)
                toastMessage = confirmed ? "Hlas potvrzen" : "Hlas odeslán"
                // bin uz neni pending — zavreme sheet
                if updated.status != .pending { viewModel.select(nil) }
            }
        )
        .presentationDetents([.fraction(0.55), .large])
        .presentationBackground(Color(.systemGroupedBackground))
    }
}

#Preview {
    MapView(viewModel: MapViewModel())
}
