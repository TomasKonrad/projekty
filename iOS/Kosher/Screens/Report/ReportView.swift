import SwiftUI

struct ReportView: View {
    @State private var viewModel: ReportViewModel
    @State private var toastMessage: String? = nil
    let location: RecyclingLocation
    let onDismiss: () -> Void

    init(location: RecyclingLocation, reporterId: String, onDismiss: @escaping () -> Void) {
        self.location = location
        self.onDismiss = onDismiss
        self.viewModel = ReportViewModel(location: location, reporterId: reporterId)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // záznam pro report
                LocationRowView(location: location)
                    .padding()

                Text("Vyberte prosím kategorii, která odpovídá Vašemu problému (max 1 kategorie).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                // Seznam typů reportu
                VStack(spacing: 0) {
                    ForEach(ReportType.allCases) { type in
                        Button {
                            viewModel.state.selectedType = type
                        } label: {
                            HStack {
                                Text(type.label)
                                    .font(.body)
                                    .foregroundStyle(Color(.label))
                                Spacer()
                                Image(systemName: viewModel.state.selectedType == type
                                      ? "checkmark.circle.fill"
                                      : "circle")
                                    .foregroundStyle(viewModel.state.selectedType == type
                                                     ? Color.primary : .secondary)
                            }
                            .padding()
                        }
                        Divider()
                            .padding(.leading)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()

                if let error = viewModel.state.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()

                // Tlačítko odeslat
                Button {
                    Task {
                        await viewModel.submit()
                        if viewModel.state.isSubmitted {
                            toastMessage = "Report byl odeslán"
                            try? await Task.sleep(for: .milliseconds(1200))
                            onDismiss()
                        }
                    }
                } label: {
                    Group {
                        if viewModel.state.isLoading {
                            HStack(spacing: 8) {
                                ProgressView().tint(.white)
                                Text("Odesílání...")
                                    .font(.body.weight(.semibold))
                            }
                        } else {
                            Text("Odeslat")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        viewModel.state.selectedType != nil ? Color.primary : Color(.systemGray4),
                        in: Capsule()
                    )
                }
                .disabled(viewModel.state.selectedType == nil || viewModel.state.isLoading)
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .toast(message: $toastMessage)
            .navigationTitle("Nahlásit problém")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    ReportView(
        location: .getSample(),
        reporterId: "user_1",
        onDismiss: {}
    )
}

#Preview("S mock managerem") {
    ReportView(
        location: .getSample(),
        reporterId: "user_1",
        onDismiss: {}
    )
}
