import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @State private var viewModel: AuthViewModel
    var onSignedIn: (() -> Void)?

    init(viewModel: AuthViewModel = AuthViewModel(), onSignedIn: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSignedIn = onSignedIn
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // logo a nazev aplikace — horni cast obrazovky
                VStack(spacing: 20) {
                    Spacer()

                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: 8)

                    VStack(spacing: 6) {
                        Text("Kosher")
                            .font(.largeTitle.weight(.bold))
                        Text("Chytré třídění odpadu")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                // prihlaseni a chybove zpravy — dolni cast obrazovky
                VStack(spacing: 16) {

                    if let error = viewModel.state.error {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button {
                        Task {
                            await viewModel.signInWithGoogle()
                            if viewModel.state.currentUser != nil {
                                onSignedIn?()
                            }
                        }
                    } label: {
                        ZStack {
                            // obsah tlacitka — skryty kdyz se nacita
                            Text("Přihlásit se přes Google")
                                .font(.body.weight(.semibold))
                            .opacity(viewModel.state.isLoading ? 0 : 1)

                            if viewModel.state.isLoading {
                                ProgressView().tint(Color(.systemBackground))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primary, in: Capsule())
                        .foregroundStyle(Color(.systemBackground))
                    }
                    .disabled(viewModel.state.isLoading)

                    Text("Přihlášením souhlasíte s podmínkami použití.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }
}

#Preview("Výchozí") {
    AuthView(viewModel: AuthViewModel(authManager: MockAuthManager()))
}

#Preview("Banned účet") {
    let mock = MockAuthManager()
    let viewModel = AuthViewModel(authManager: mock)
    viewModel.state.error = "Váš účet byl zablokován z důvodu: nevhodný obsah"
    return AuthView(viewModel: viewModel)
}
