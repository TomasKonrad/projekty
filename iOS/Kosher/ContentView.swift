import SwiftUI

struct ContentView: View {
    // pro zapamatování, že onboarding už se zobrazil
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var viewModel        = MapViewModel()
    @State private var authViewModel    = AuthViewModel()
    // profileViewModel zije na urovni ContentView — zachovava nacteny profil mezi otevrenimy sheetu
    @State private var profileViewModel = ProfileViewModel()
    // sdileny koordinator — singleton z DI, spravuje navigaci na mapu ze skeneru a profilu
    @State private var coordinator: AppCoordinator = DIContainer.shared.resolve()
    // scannerViewModel zije na urovni ContentView — zachovava vysledky pri prepnuti na mapu a zpet
    @State private var scannerViewModel = ScannerViewModel()
    @State private var showScanner = false
    @State private var showProfile = false
    // sledovani dostupnosti site
    @State private var network = NetworkMonitor()

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView(
                coordinator: coordinator,
                onFinish: { hasSeenOnboarding = true },
                onShowProfile: {
                    hasSeenOnboarding = true
                    showProfile = true
                }
            )
        } else {
            MapView(
                viewModel: viewModel,
                onShowProfile: { showProfile = true },
                onShowScanner: { showScanner = true }
            )
            // skener — fullScreenCover kvuli vlastnimu fullscreenu pro kameru uvnitr
            .fullScreenCover(isPresented: $showScanner) {
                ScannerView(authViewModel: authViewModel, viewModel: scannerViewModel)
            }
            // profil — sheet, NavigationStack uvnitr ProfileView resi vlastni navigaci
            .sheet(isPresented: $showProfile) {
                ProfileView(
                    authViewModel: authViewModel,
                    viewModel: profileViewModel,
                    coordinator: coordinator,
                    onSignOut: { authViewModel.state.currentUser = nil }
                )
            }
            // offline banner — zobrazi se kdyz neni dostupna sit
            .overlay(alignment: .top) {
                if !network.isConnected {
                    Label("Žádné připojení k internetu", systemImage: "wifi.slash")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: Capsule())
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: network.isConnected)
            // sledujeme pending lokaci — zavreme otevrene sheety a navigujeme na mape
            .onChange(of: coordinator.pendingMapLocation?.id) { _, id in
                guard id != nil, let location = coordinator.pendingMapLocation else { return }
                showScanner = false
                showProfile = false
                viewModel.navigateTo(location)
                coordinator.pendingMapLocation = nil
            }
            .task {
                for _ in 0..<20 {
                    if authViewModel.state.currentUser != nil { break }
                    authViewModel.syncCurrentUser()
                    try? await Task.sleep(for: .milliseconds(200))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
