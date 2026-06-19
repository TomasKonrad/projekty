import SwiftUI

struct OnboardingView: View {
    // @AppStorage je tu pro zapamatování, že onboard už se zobrazil. Je to místo, kde informace přežijí i vypnutí aplikace
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    let coordinator: AppCoordinator
    let onFinish: () -> Void
    let onShowProfile: () -> Void

    var body: some View {
        TabView(selection: $currentPage) {

            // Onboarding 1 – Uvítání
            OnboardingPageTemplate(
                title: "Vítej v Kosher",
                description: "Váš pomocník pro třídění odpadu.",
                logo: "logo",
                buttonLabel: "Začít",
                onNext: { currentPage = 1 }
            )
            .tag(0)

            // Onboarding 2 – Mapa
            OnboardingPageTemplate(
                title: "Najdi sběrné místo",
                description: "Vyhledávajte na mapě nejbližší koše, kontejnery, sběrné dvory a informace o nich.",
                screenshot: "Map",
                buttonLabel: "Další",
                onNext: { currentPage = 2 }
            )
            .tag(1)

            // Onboarding 3 – AIScanner
            OnboardingPageTemplate(
                title: "AI skener odpadu",
                description: "Zjednodušte si recyklování pomocí AI skeneru, který vám dá instrukce ke správnému zlikvidování odpadu.",
                screenshot: "AIScanner_result",
                buttonLabel: "Další",
                onNext: { currentPage = 3 }
            )
            .tag(2)

            // Onboarding 4 – Komunita
            OnboardingPageTemplate(
                title: "Přidávej sběrná místa",
                description: "Pomozte nám udržovat mapu aktuální. Přidávejte nová místa, nahlašujte problémy a potvrzujte správnost údajů pro lidi ve vašem okolí.",
                screenshot: "AddBin1",
                buttonLabel: "Další",
                onNext: { currentPage = 4 }
            )
            .tag(3)

            // Onboarding 5 – Přihlášení
            OnboardingPageTemplate(
                title: "Začni recyklovat",
                description: "Zaregistruj se pro přístup ke všem funkcím nebo pokračuj bez přihlášení.",
                buttonLabel: "Pokračovat bez přihlášení",
                isLastPage: true,
                signInButtonLabel: "Zaregistrovat se",
                onNext: {
                    onFinish()
                },
                onSignIn: {
                    onFinish()
                    onShowProfile()
                }
            )
            .tag(4)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }
}

// MARK: - previews

#Preview {
    OnboardingView(
        coordinator: AppCoordinator(),
        onFinish: {},
        onShowProfile: {}
    )
}
