import SwiftUI

struct OnboardingPageTemplate: View {
    let title: String
    let description: String
    let logo: String?
    let screenshot: String?
    let buttonLabel: String
    let isLastPage: Bool
    let signInButtonLabel: String?
    let onNext: () -> Void
    let onSignIn: () -> Void
    
    // init, aby jsme některé parametry nemusely zadávat
    init(
        title: String,
        description: String,
        screenshot: String? = nil,
        logo: String? = nil,
        buttonLabel: String = "Další",
        isLastPage: Bool = false,
        signInButtonLabel: String? = nil,
        onNext: @escaping () -> Void,
        onSignIn: @escaping () -> Void = {}
    ) {
        self.title = title
        self.description = description
        self.screenshot = screenshot
        self.logo = logo
        self.buttonLabel = buttonLabel
        self.isLastPage = isLastPage
        self.signInButtonLabel = signInButtonLabel
        self.onNext = onNext
        self.onSignIn = onSignIn
    }
    
    var body: some View {
        ZStack {
            Image("onboarding_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if let logo {
                    // uvítací onboard — logo + text uprostřed
                    Spacer()
                    VStack(spacing: 16) {
                        Image("logo_white")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        Text(title)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    Spacer()

                } else if let screenshot {
                    // screenshot onboard — screenshot nahoře, text dole
                    Image(screenshot)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                        .padding(.horizontal, 48)
                        .padding(.top, 80)
                        .padding(.bottom, 32)
                    Spacer()
                    VStack(spacing: 12) {
                        Text(title)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                    Spacer()

                } else {
                    // přihlašovací onboard — jen text uprostřed
                    Spacer()
                    VStack(spacing: 12) {
                        Text(title)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)
                    Spacer()
                }

                // tlačítko pro přihlášení
                if let signInButtonLabel{
                    Button(action: onSignIn) {
                        Text(signInButtonLabel)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white, in: Capsule())
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 12)
                }
                
                Button(action: onNext) {
                    Text(buttonLabel)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.25), in: Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 80)
            }
        }
    }
}

// MARK: - previews
#Preview("Se screenshotem") {
    OnboardingPageTemplate(
        title: "Najdi sběrné místo",
        description: "Vyhledávajte na mapě nejbližší koše, kontejnery, sběrné dvory a informace o nich.",
        screenshot: "Map",
        buttonLabel: "Další",
        isLastPage: false,
        onNext: {}
    )
}

#Preview("Uvítací onboard") {
    OnboardingPageTemplate(
        title: "Vítej v Kosher",
        description: "Zjednodušte si recyklování pomocí AI skeneru, který vám dá instrucke pro správné zlikvidování.",
        logo: "logo",
        buttonLabel: "Začít",
        isLastPage: true,
        onNext: {}
    )
}
    
    #Preview("Textový onboard") {
        OnboardingPageTemplate(
            title: "Vítej v Kosher",
            description: "Aplikace která ti pomůže třídit odpad správně.",
            buttonLabel: "Začít",
            isLastPage: true,
            onNext: {}
        )
}
