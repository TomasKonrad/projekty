import SwiftUI
import PhotosUI

struct ScannerView: View {
    // je potřeba pro přihlášení ve scanneru
    let authViewModel: AuthViewModel
    // viewModel predavan zvenci — zachovava stav pri zavreni skeneru a navratu z mapy
    @State private var viewModel: ScannerViewModel
    @State private var showCamera = false
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var expandedItemId: UUID? = nil
    @Environment(\.dismiss) private var dismiss
    
    // zjištění aktuálního uživatele
    init(authViewModel: AuthViewModel, viewModel: ScannerViewModel = ScannerViewModel()) {
        self.authViewModel = authViewModel
        self._viewModel = State(initialValue: viewModel)
    }

    private var currentUser: AppUser? {
        authViewModel.state.currentUser
    }

    private var isAnalyzing: Bool {
        if case .analyzing = viewModel.state.loadingState { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Group {
                // uživatel není přihlášen = notLoggedInView s tlačítkem pro přihlášení
                if currentUser == nil {
                    notLoggedInView
                    // přihlášený uživatel = zorazení stavových obrazovek scanneru
                } else {
                    switch viewModel.state.loadingState {
                    case .idle:          idleView
                    case .analyzing:     analyzingView
                    case .done:          resultsView
                    case .failed(let m): errorView(m)
                    }
                }
            }
            .navigationTitle(isAnalyzing ? "" : "Naskenovaný odpad")
            .navigationBarTitleDisplayMode(.inline)
            // nav bar schovame behem analyzy — bez nej je content area temer cely ekran
            .toolbar(isAnalyzing ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                // tlacitko zavreni — skener je fullScreenCover, nema swipe-to-dismiss
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in Task { await viewModel.analyze(image: image) } }
        }
        .onChange(of: photoItem) { _, new in
            guard let new else { return }
            Task {
                if let data = try? await new.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await viewModel.analyze(image: image)
                }
                photoItem = nil
            }
        }
    }

    // MARK: - Vychozi stav

    private var idleView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(.secondary)
                VStack(spacing: 8) {
                    Text("Identifikace odpadu")
                        .font(.title2.weight(.bold))
                    Text("Vyfoťte nebo vyberte fotografii odpadu\na my vám řekneme, kam ho vyhodit.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            Spacer()
            VStack(spacing: 12) {
                Button { showCamera = true } label: {
                    Label("Vyfotit", systemImage: "camera")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primary, in: Capsule())
                }
                .buttonStyle(.plain)
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Vybrat z galerie", systemImage: "photo.on.rectangle")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground), in: Capsule())
                        .overlay(Capsule().stroke(Color.primary, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Stav analyzy — foto na celem ekranu, spinner uprostred

    private var analyzingView: some View {
        ZStack {
            if let img = viewModel.state.selectedImage {
                // frame + clipped zajisti ze obraz neroztahne ZStack za jeho hranice
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()  // foto se roztahne za status bar
            }
            // prehlezovy overlay taky za safe area aby nepustil bily okraj
            Color.black.opacity(0.5).ignoresSafeArea()
            // VStack se vystreduje v content area ZStacku (pod status barem, nad tab barem)
            VStack(spacing: 16) {
                ProgressView().tint(.white).scaleEffect(1.2)
                Text("Analyzuji fotografii…")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Vysledky analyzy

    private var resultsView: some View {
        VStack(spacing: 0) {
            if viewModel.state.results.isEmpty {
                // prazdny stav — AI nic neidentifikovalo
                VStack(spacing: 24) {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 56, weight: .thin))
                            .foregroundStyle(.secondary)
                        VStack(spacing: 6) {
                            Text("Nic nebylo identifikováno")
                                .font(.title3.weight(.semibold))
                            Text("Zkuste vyfotit odpad zblízka\na na světlém pozadí.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.state.results) { item in
                            ResultRowView(
                                item: item,
                                isExpanded: expandedItemId == item.id,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        expandedItemId = expandedItemId == item.id ? nil : item.id
                                    }
                                },
                                onShowOnMap: { location in viewModel.showOnMap(location: location) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
            }

            // tlacitko pro novou fotografii — vzdy viditelne v obou stavech
            Button { viewModel.reset() } label: {
                Text("Nová fotografie")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground), in: Capsule())
                    .overlay(Capsule().stroke(Color(.systemGray4), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Chybovy stav

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Zkusit znovu") { viewModel.reset() }
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.primary)
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    // MARK: - view pro nepřihlášeného uživatele

    private var notLoggedInView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text("Vyžadováno přihlášení")
                    .font(.title2.weight(.bold))
                Text("Pro použití AI skeneru se prosím přihlaste.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            
            // tlačítko přihlásít jako u profilu
            Button {
                Task {
                    // volání funkce z auth, po přihlášení se zobrazí stav scanneru
                    await authViewModel.signInWithGoogle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image("google_logo")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Přihlásit se přes Google")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primary, in: Capsule())
                .foregroundStyle(Color(.systemBackground))
            }
            .padding(.horizontal)
            .disabled(authViewModel.state.isLoading)
            
            if authViewModel.state.isLoading {
                ProgressView()
            }

            if let error = authViewModel.state.error {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}


// MARK: - Previews

#Preview("Nepřihlášený") {
    ScannerView(authViewModel: AuthViewModel(authManager: MockAuthManager()))
}

#Preview("Přihlášený") {
    let viewModel = AuthViewModel(authManager: MockAuthManager())
    viewModel.state.currentUser = .getSample()
    return ScannerView(authViewModel: viewModel)
}
