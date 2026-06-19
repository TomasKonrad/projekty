import SwiftUI
import MapKit
import PhotosUI

struct AddBinView: View {
    @State private var viewModel: AddBinViewModel
    @State private var isCameraPresented = false
    @State private var isGalleryPresented = false
    @Environment(\.dismiss) private var dismiss
    // volano po uspesnem ulozeni — v rezimu upravy predava aktualizovanou lokaci
    var onSaved: ((RecyclingLocation) -> Void)?

    init(viewModel: AddBinViewModel, onSaved: ((RecyclingLocation) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSaved = onSaved
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                photoSection
                categorySection
                wasteTypeSection
                locationSection
                // upozorneni ze lokace ceka na schvaleni
                Text("Po přidání bude sběrné místo čekat na potvrzení ostatními uživateli, nebo moderátorem.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 96) // prostor pro pevne tlacitko
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(viewModel.isEditing ? "Upravit sběrné místo" : "Přidat sběrné místo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { submitButton }
        .task { await viewModel.loadAddress() }
        .onChange(of: viewModel.state.selectedPhotoItem) { _, new in
            Task { await viewModel.loadPhoto(from: new) }
        }
        .alert("Chyba", isPresented: Binding(
            get: { viewModel.state.error != nil },
            set: { if !$0 { viewModel.state.error = nil } }
        )) {
            Button("OK") { viewModel.state.error = nil }
        } message: {
            Text(viewModel.state.error ?? "")
        }
        .onChange(of: viewModel.state.didSave) { _, saved in
            guard saved else { return }
            if let updated = viewModel.state.savedLocation { onSaved?(updated) }
            dismiss()
        }
        .photosPicker(isPresented: $isGalleryPresented, selection: $viewModel.state.selectedPhotoItem, matching: .images)
    }

    // MARK: - Sekce fotek

    private var photoSection: some View {
        sectionContainer("Fotografie") {
            if let img = viewModel.state.selectedImage {
                // nahlad vybrane fotky s moznosti zmeny
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(alignment: .bottomTrailing) {
                        Menu {
                            Button { isCameraPresented = true } label: {
                                Label("Vyfotit", systemImage: "camera")
                            }
                            Button { isGalleryPresented = true } label: {
                                Label("Vybrat z galerie", systemImage: "photo.on.rectangle")
                            }
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(Color.primary, in: Circle())
                        }
                        .padding(10)
                    }
            } else {
                // placeholder s menu pro vyber zdroje fotky
                Menu {
                    Button { isCameraPresented = true } label: {
                        Label("Vyfotit", systemImage: "camera")
                    }
                    Button { isGalleryPresented = true } label: {
                        Label("Vybrat z galerie", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color(.systemGray), style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "camera")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color(.systemGray2))
                                Text("Přidat fotografii")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color(.systemGray))
                            }
                        }
                }
            }
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView { image in
                viewModel.state.selectedImage = image
                viewModel.state.selectedPhotoItem = nil
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Sekce kategorie

    private var categorySection: some View {
        sectionContainer("Kategorie") {
            HStack(spacing: 12) {
                ForEach(AddBinViewModel.availableCategories) { category in
                    categoryCard(category)
                }
            }
        }
    }

    private func categoryCard(_ category: LocationCategory) -> some View {
        let selected = viewModel.state.selectedCategory == category
        return Button { viewModel.selectCategory(category) } label: {
            VStack(spacing: 8) {
                Image(systemName: category.mapIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(selected ? Color.primary : Color(.systemGray2))
                Text(category.label)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(selected ? Color.primary : Color(.systemGray))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(selected ? Color.primary : Color(.systemGray), lineWidth: selected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: selected)
    }

    // MARK: - Sekce typu odpadu

    private var wasteTypeSection: some View {
        let isLocked = viewModel.state.selectedCategory == .wasteBasket
        let types: [WasteType] = isLocked ? [.mixed] : AddBinViewModel.recyclingWasteTypes
        return sectionContainer("Typ odpadu") {
            FlowLayout(spacing: 8) {
                ForEach(types) { type in
                    let isSelected = viewModel.state.selectedWasteTypes.contains(type)
                    FilterChip(label: type.label, isSelected: isSelected) {
                        viewModel.toggleWasteType(type)
                    }
                    .disabled(isLocked)
                }
            }
        }
    }

    // MARK: - Sekce lokace

    private var locationSection: some View {
        sectionContainer("Lokace") {
            VStack(alignment: .leading, spacing: 10) {
                mapThumbnail
                if viewModel.state.isLoadingAddress {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let address = viewModel.state.address {
                    Label(address, systemImage: "mappin")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 12) {
                    coordinateCard(label: "Latitude",  value: viewModel.coordinate.latitude)
                    coordinateCard(label: "Longitude", value: viewModel.coordinate.longitude)
                }
            }
        }
    }

    private var mapThumbnail: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: viewModel.coordinate,
            latitudinalMeters: 300,
            longitudinalMeters: 300
        )), interactionModes: []) {
            Marker("", coordinate: viewModel.coordinate)
                .tint(.red)
        }
        .mapControls { }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func coordinateCard(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(format: "%.6f", value))
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Tlacitko odeslani

    private var submitButton: some View {
        // pri uprave fotka neni povinna — zachovava se puvodni; pri pridani je povinna
        let canSubmit = (viewModel.isEditing || viewModel.state.selectedImage != nil)
            && !viewModel.state.selectedWasteTypes.isEmpty
            && !viewModel.state.isSaving
        return Button {
            Task { await viewModel.submit() }
        } label: {
            Group {
                if viewModel.state.isSaving {
                    ProgressView().tint(.white)
                } else {
                    Text(viewModel.isEditing ? "Uložit" : "Přidat")
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canSubmit ? Color.primary : Color(.systemGray3), in: Capsule())
        }
        .disabled(!canSubmit)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Pomocny kontejner sekce

    private func sectionContainer<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
    }
}
