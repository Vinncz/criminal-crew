import SwiftUI

struct TutorialView: View {
    @State private var currentIndex = 0
    private let tutorialItems = ["tutorial_page1", "tutorial_page2", "tutorial_page3", "tutorial_page4", "tutorial_page5"]
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
         var dismiss       : () -> Void
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    HStack {
                        CustomButton(
                            defaultImage: "back_button_default",
                            pressedImage: "back_button_pressed",
                            action: {
                                AudioManager.shared.playSoundEffect(fileName: "button_on_off")
                                relay?.dismiss()
                            },
                            isDisabled: false
                        )
                        .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.top, 10)

                    TabView(selection: $currentIndex) {
                        ForEach(0..<tutorialItems.count, id: \.self) { index in
                            TutorialCardView(title: tutorialItems[index])
                                .tag(index)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    HStack {
                        if currentIndex > 0 {
                            CustomButtonRectangle(
                                defaultImage: "prev_button_default",
                                pressedImage: "prev_button_pressed",
                                action: {
                                    withAnimation(.easeInOut) {
                                        currentIndex -= 1
                                    }
                                },
                                isDisabled: false
                            )
                            .frame(minWidth: 90, minHeight: 90)
                        }

                        Spacer()

                        if currentIndex < tutorialItems.count - 1 {
                            CustomButtonRectangle(
                                defaultImage: "next_button_default",
                                pressedImage: "next_button_pressed",
                                action: {
                                    withAnimation(.easeInOut) {
                                        currentIndex += 1
                                    }
                                    
                                },
                                isDisabled: false
                            )
                        }
                    }
                    .padding(.horizontal, 50)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - CustomButton Component
struct CustomButton: View {
    let defaultImage: String
    let pressedImage: String
    let action: () -> Void
    let isDisabled: Bool

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            Image(isPressed ? pressedImage : defaultImage)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isDisabled {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .disabled(isDisabled)
    }
}

// MARK: - CustomButton Component
struct CustomButtonRectangle: View {
    let defaultImage: String
    let pressedImage: String
    let action: () -> Void
    let isDisabled: Bool

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if !isDisabled {
                action()
            }
        }) {
            Image(isPressed ? pressedImage : defaultImage)
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 40)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isDisabled {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .disabled(isDisabled)
    }
}

struct TutorialCardView: View {
    let title: String

    var body: some View {
        Image(title)
            .resizable()
            .scaledToFit()
            .padding()
    }
}
