import SwiftUI

struct MainMenuView : View, UsesDependenciesInjector {
    
    var relay: Relay?
    struct Relay : CommunicationPortal {
        var makeServerVisible   : ([String: String]) -> Void
        var admitTheHost        : () -> Void
        var navigateTo          : (UIViewController) -> Void
        var communicateToServer : (Data) throws -> Void
    }
    
    var body : some View {
        NavigationStack {
            VStack ( alignment: .leading ) {
                Spacer()
                HStack {
                    VStack ( alignment: .leading ) {
                        Text("Criminal\nCrew")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .padding(.top, UIViewConstants.Paddings.normal)
                        
                        Spacer()
                        
                        NavigationLink {
                            Text("Fuck you")
                        } label: {
                            HStack {
                                Spacer()
                                Text("Join Game")
                                Spacer()
                            }
                                .padding(.horizontal, UIViewConstants.Paddings.huge * 2)
                                .padding(.vertical, UIViewConstants.Paddings.mini)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: UIViewConstants.CornerRadiuses.normal))
                        }
                        
                        NavigationLink {
                            Text("Fuck you")
                        } label: {
                            HStack {
                                Spacer()
                                Text("Host Game Room")
                                Spacer()
                            }
                                .padding(.horizontal, UIViewConstants.Paddings.huge * 2)
                                .padding(.vertical, UIViewConstants.Paddings.mini)
                                .padding()
                                .background(.blue.opacity(0.3))
                                .foregroundStyle(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: UIViewConstants.CornerRadiuses.normal))
                        }
                    }
                    .padding(.all, UIViewConstants.Paddings.huge)
                    Spacer()
                    Circle()
                        .size(.init(width: 750, height: 750))
                        .ignoresSafeArea()
                }
            }
        }
    }
    
}

#Preview {
    MainMenuView()
}
