import UIKit

class BrowseRoomsViewController : UIViewController, UsesDependenciesInjector {
    
    let bRefreshBrowser : UIButton
    
    override init ( nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle? ) {
        self.bRefreshBrowser = UIButton().titled("Refresh").styled(.text).tagged(Self.refreshBrowser)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? ( coder: NSCoder ) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var relay : Relay?
    public struct Relay : CommunicationPortal {
        var navigateTo : (UIViewController) -> Void
        weak var networkManager : ClientComposer?
    }
    
}

extension BrowseRoomsViewController {
    
    override func viewDidLoad () {
        _ = bRefreshBrowser.executes(self, action: #selector(refreshServerBrowser), for: .touchUpInside)
        
        let vstack = Self.makeStack(direction: .vertical, distribution: .fillProportionally).thatHolds(bRefreshBrowser)
        
        view.addSubview(vstack)
        
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vstack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
}

extension BrowseRoomsViewController {
    
    @objc func refreshServerBrowser () {
        guard
            let relay = relay,
            let nm = relay.networkManager
        else { return }
        print("started browsing")
    }
    
}

extension BrowseRoomsViewController {
    
    fileprivate static let refreshBrowser : Int = 0
    
}
