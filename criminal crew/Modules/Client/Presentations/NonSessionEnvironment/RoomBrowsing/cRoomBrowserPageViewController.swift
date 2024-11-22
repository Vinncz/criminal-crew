import Combine
import UIKit
import os

public class RoomBrowserPageViewController : UIViewController {
    
    let bRefreshBrowser    : UIButton
    let tDiscoveredServers : UITableView
    public let bBackButton : UIButton
    public let bSettings : UIButton
    
    private let backButtonId = 1
    private let settingsButtonId = 2
    
    public var subscriptions : Set<AnyCancellable> = []
    
    public var relay    : Relay?
    public struct Relay : CommunicationPortal {
        weak var selfSignalCommandCenter : SelfSignalCommandCenter?
        weak var playerRuntimeContainer  : ClientPlayerRuntimeContainer?
        weak var serverBrowser           : ClientGameBrowser?
        weak var panelRuntimeContainer   : ClientPanelRuntimeContainer?
        weak var gameRuntimeContainer    : ClientGameRuntimeContainer?
             var navigate                : (( _ to: UIViewController ) -> Void)?
             var popViewController       : (() -> Void)?
             var dismiss                : (() -> Void)?
    }
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.bRefreshBrowser    = UIButton().styled(.secondary).tagged(Self.refreshBrowser).withIcon(systemName: "arrow.trianglehead.clockwise.rotate.90")
        self.tDiscoveredServers = UITableView()
        self.bBackButton = ButtonWithImage(imageName: "back_button_default", tag: backButtonId)
        self.bSettings    = ButtonWithImage(imageName: "setting_button_default", tag: settingsButtonId)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private let consoleIdentifier: String = "[C-BRP]"
    
}

extension RoomBrowserPageViewController {
    
    public override func viewDidLoad () {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        let backgroundView = UIImageView(image: UIImage(named: "background_laptop_screen_with_wall"))
        backgroundView.contentMode = .scaleToFill
        backgroundView.isUserInteractionEnabled = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupBackButton()
        setupSettingButton()
        
        self.relay?.gameRuntimeContainer?.state = .searchingForServers
        
        _ = bRefreshBrowser.executes(self, action: #selector(refreshServerBrowser), for: .touchUpInside)
        
        let tableBackgroundView = UIImageView(image: UIImage(named: "background_list_room"))
        tableBackgroundView.contentMode = .scaleToFill
        tableBackgroundView.isUserInteractionEnabled = true
        tableBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableBackgroundView)
        
        NSLayoutConstraint.activate([
            tableBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            tableBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55)
        ])
        
        tableBackgroundView.addSubview(tDiscoveredServers)
        tDiscoveredServers.register(RoomCell.self, forCellReuseIdentifier: RoomCell.identifier)
        tDiscoveredServers.delegate = self
        tDiscoveredServers.dataSource = self
        tDiscoveredServers.backgroundColor = .clear
        tDiscoveredServers.separatorStyle = .none
        tDiscoveredServers.allowsSelection = true
        tDiscoveredServers.isUserInteractionEnabled = true
        tDiscoveredServers.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tDiscoveredServers.topAnchor.constraint(equalTo: tableBackgroundView.topAnchor, constant: 32),
            tDiscoveredServers.leadingAnchor.constraint(equalTo: tableBackgroundView.leadingAnchor, constant: 16),
            tDiscoveredServers.trailingAnchor.constraint(equalTo: tableBackgroundView.trailingAnchor, constant: -16),
            tDiscoveredServers.bottomAnchor.constraint(equalTo: tableBackgroundView.bottomAnchor, constant: -16)
        ])
        
        _ = self.relay?.selfSignalCommandCenter?.startBrowsingForServers()
        enableUpdateJobForDiscoveredServers()
        AudioManager.shared.playBackgroundMusic(fileName: "bgm_lobby")
    }
    
    override public func viewDidDisappear ( _ animated: Bool ) {
        super.viewDidDisappear(animated)
        AudioManager.shared.stopBackgroundMusic()
        subscriptions.forEach { $0.cancel() }
    }
    
    private func setupBackButton() {
        bBackButton.imageView?.contentMode = .scaleAspectFit
        bBackButton.addTarget(self, action: #selector(ButtonTapped), for: .touchUpInside)
        view.addSubview(bBackButton)
        bBackButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bBackButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bBackButton.widthAnchor.constraint(equalToConstant: 45.0),
            bBackButton.heightAnchor.constraint(equalToConstant: 45.0)
        ])
    }
    
    private func setupSettingButton() {
        bSettings.imageView?.contentMode = .scaleAspectFit
        bSettings.addTarget(self, action: #selector(ButtonTapped), for: .touchUpInside)
        view.addSubview(bSettings)
        bSettings.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bSettings.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bSettings.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            bSettings.widthAnchor.constraint(equalToConstant: 45.0),
            bSettings.heightAnchor.constraint(equalToConstant: 45.0)
        ])
    }
    
}

extension RoomBrowserPageViewController {
    
    private func enableUpdateJobForDiscoveredServers () {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to enable update job for discovered servers: relay is missing or not set")
            return
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to enable update job for discovered servers: serverBrowser is missing or not set")
            return
        }
        
        serverBrowser.$discoveredServers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tDiscoveredServers.reloadData()
                debug("Reloading discovered server list with \(serverBrowser.discoveredServers)")
            }.store(in: &subscriptions)

        debug("\(consoleIdentifier) Did enable update job for discovered servers") 
    }
    
}

extension RoomBrowserPageViewController {
    
    @objc private func ButtonTapped(_ sender: UIButton) {
        AudioManager.shared.playSoundEffect(fileName: "button_on_off")
        guard let relay else {
            debug("\(consoleIdentifier) Unable to cue navigation. Relay is missing or not set")
            return
        }
        
        switch ( sender.tag ) {
            case backButtonId:
                relay.popViewController?()
                break
            case settingsButtonId:
                let settingPage = SettingGameViewController()
                settingPage.relay = SettingGameViewController.Relay (
                    dismiss: {
                        self.relay?.dismiss?()
                    }
                )
                relay.navigate?(settingPage)
                break
            default:
                debug("\(consoleIdentifier) Unhandled button tag: \(sender.tag)")
                break
        }
    }
    
    @objc func refreshServerBrowser () {
        guard let relay else {
            debug("\(consoleIdentifier) Did fail to refresh server browser: relay is missing or not set"); return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to refresh server browser: selfSignalCommandCenter is missing or not set"); return
        }
        
        _ = selfSignalCommandCenter.resetBrowser()
        _ = selfSignalCommandCenter.startBrowsingForServers()
        tDiscoveredServers.reloadData()
    }
    
}

// TODO: Refac
extension RoomBrowserPageViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView ( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to get number of rows in section: relay is missing or not set"); return 0
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to get number of rows in section: serverBrowser is missing or not set"); return 0
        }
        
        debug("Table delegate did return \(serverBrowser.discoveredServers.count) rows")
        return serverBrowser.discoveredServers.count
    }
    
    public func tableView ( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        print("did get called for cell for row at index path")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.identifier, for: indexPath) as? RoomCell else {
            return UITableViewCell()
        }
        
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to get cell for row at index path: relay is missing or not set"); return cell
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to get cell for row at index path: serverBrowser is missing or not set"); return cell
        }
        
        debug("Did try to access discoveredServers array at index \(indexPath.row)")
        let extractedRoomName      = serverBrowser.discoveredServers[indexPath.row].discoveryContext["roomName"] ?? "Unnamed Room"
        
        let extractedRoomId = "ID"
        
        cell.configure(roomName: extractedRoomName, roomIndex: indexPath.row + 1, roomId: extractedRoomId)
        cell.selectionStyle = .default
        
        if indexPath.row % 2 == 0 {
            cell.tableView.backgroundColor = UIColor(cgColor: CGColor(red: 199.0/255.0, green: 207.0/255.0, blue: 204.0/255.0, alpha: 1.0))
        } else {
            cell.tableView.backgroundColor = UIColor(cgColor: CGColor(red: 168.0/255.0, green: 181.0/255.0, blue: 178.0/255.0, alpha: 1.0))
        }
        
        return cell
    }
    
    public func tableView ( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        AudioManager.shared.playSoundEffect(fileName: "button_on_off")
        guard let relay = self.relay else {
            debug("\(consoleIdentifier) Did fail to handle didSelectRowAt: relay is missing or not set"); return
        }
        
        guard let serverBrowser = relay.serverBrowser else {
            debug("\(consoleIdentifier) Did fail to handle didSelectRowAt: serverBrowser is missing or not set"); return
        }
        
        guard let selfSignalCommandCenter = relay.selfSignalCommandCenter else {
            debug("\(consoleIdentifier) Did fail to handle didSelectRowAt: selfSignalCommandCenter is missing or not set"); return
        }
        
        let selectedServer = serverBrowser.discoveredServers[indexPath.row]
        _ = selfSignalCommandCenter.sendJoinRequest(to: selectedServer.serverId)
        guard let cell = tableView.cellForRow(at: indexPath) as? RoomCell else {
            debug("\(consoleIdentifier) Could not retrieve RoomCell for indexPath: \(indexPath)")
            return
        }
        let roomName = cell.roomName
        guard let gameRuntimeContainer = relay.gameRuntimeContainer
        else {
            Logger.client.error("\(self.consoleIdentifier) failed to handle didSelectRowAt: gameRuntimeContainer is missing")
            return
        }
        gameRuntimeContainer.playedRoomName = roomName
        _ = selfSignalCommandCenter.stopBrowsingForServers()
        
        let lobbyViewController = LobbyViewController()
        lobbyViewController.relay = LobbyViewController.Relay (
            selfSignalCommandCenter : self.relay?.selfSignalCommandCenter,
            playerRuntimeContainer  : self.relay?.playerRuntimeContainer,
            panelRuntimeContainer   : self.relay?.panelRuntimeContainer,
            gameRuntimeContainer    : self.relay?.gameRuntimeContainer,
            serverBrowser           : self.relay?.serverBrowser,
            navigate                : { [weak self] to in
                debug("lobby view did navigate from room browser")
                self?.relay?.navigate?(to)
            },
            popViewController: {
                self.relay?.popViewController?()
            },
            dismiss: {
                self.relay?.dismiss?()
            }
        )
        
        relay.navigate?(lobbyViewController)
    }
    
}

extension RoomBrowserPageViewController {
    
    fileprivate static let consoleLogDiscoveredServers = 0
    fileprivate static let refreshBrowser = 1
    
}

#Preview {
    RoomBrowserPageViewController()
}
