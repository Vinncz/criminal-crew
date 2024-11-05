import UIKit

public class cCardSwipeViewController: BaseGameViewController {
    
    public var cardSwiperPart = UIImageView()
    public var swipeCard = UIImageView()
    
    public var numPadButton = UIImageView()
    public var numPadPanel = UIImageView()
    public var numPadDeleteButton = UIImageView()
    public var numPadEnterButton = UIImageView()
    
    public var numPadButtonNumber: String?
    public var numPadPanelNumber: String?
    
    public var swipeCards = [UIImageView]()
    public var containerView: UIView?
    public var landscapeContainerView: UIView?
    
    public override func createFirstPanelView() -> UIView {
        
        containerView = UIView()
        
        guard let containerView else {
            return UIView()
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(containerView)
        
        let portraitBackgroundImage = ViewFactory.addBackgroundImageView("BG Swiper")
        portraitBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(portraitBackgroundImage)
        
        setupViewsForFirstPanel(for: containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            portraitBackgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor),
            portraitBackgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            portraitBackgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            portraitBackgroundImage.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.45)
        ])
        
        constraintForFirstPanel(for: containerView)
        
        return containerView
    }
    
    public override func createSecondPanelView() -> UIView {
        
        landscapeContainerView = UIView()
        
        guard let landscapeContainerView else {
            return UIView()
        }
        
        landscapeContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(landscapeContainerView)
        
        let landscapeBackgroundImage = ViewFactory.addBackgroundImageView("BG Numpad")
        landscapeBackgroundImage.translatesAutoresizingMaskIntoConstraints = false
        landscapeContainerView.addSubview(landscapeBackgroundImage)
        
        setupViewsForSecondPanel(for: landscapeContainerView)
        
        NSLayoutConstraint.activate([
            landscapeContainerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            landscapeContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            landscapeContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            landscapeContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            landscapeBackgroundImage.topAnchor.constraint(equalTo: landscapeContainerView.topAnchor),
            landscapeBackgroundImage.leadingAnchor.constraint(equalTo: landscapeContainerView.leadingAnchor),
            landscapeBackgroundImage.trailingAnchor.constraint(equalTo: landscapeContainerView.trailingAnchor),
            landscapeBackgroundImage.heightAnchor.constraint(equalTo: landscapeContainerView.heightAnchor)
        ])
        
//        constraintForFirstPanel(for: containerView)
        
        return landscapeContainerView
    }
    
    public override func setupGameContent() {
        
    }
    
    func setupViewsForFirstPanel(for target: UIView) {
        
        cardSwiperPart.image = UIImage(named: "cardSwipeOff")
        cardSwiperPart.contentMode = .scaleAspectFit
        cardSwiperPart.translatesAutoresizingMaskIntoConstraints = false
        target.addSubview(cardSwiperPart)

        let cardColors = ["Green", "Blue", "Yellow", "Red"]
        for color in cardColors {
            let swipeCard = UIImageView(image: UIImage(named: "swipeCard\(color)"))
            swipeCard.contentMode = .scaleAspectFit
            swipeCard.translatesAutoresizingMaskIntoConstraints = false
            target.addSubview(swipeCard)
            swipeCards.append(swipeCard)
        }
    }

    func constraintForFirstPanel(for target: UIView) {

        let cardWidth: CGFloat = 220
        let cardHeight: CGFloat = 120
        let cardYSpacing: CGFloat = -90
        let cardXSpacing: CGFloat = 25
        let yLevelSpacing: CGFloat = 10

        NSLayoutConstraint.activate([
            cardSwiperPart.widthAnchor.constraint(equalTo: target.widthAnchor, multiplier: 0.8),
            cardSwiperPart.heightAnchor.constraint(equalTo: target.heightAnchor, multiplier: 0.6),
            cardSwiperPart.centerXAnchor.constraint(equalTo: target.centerXAnchor),
            cardSwiperPart.topAnchor.constraint(equalTo: target.topAnchor)
        ])

        for (index, card) in swipeCards.enumerated() {
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: cardWidth),
                card.heightAnchor.constraint(equalToConstant: cardHeight),
                
                card.centerXAnchor.constraint(equalTo: target.centerXAnchor, constant: -30 + CGFloat(index) * cardXSpacing),
                
                card.topAnchor.constraint(equalTo: index == 0 ? cardSwiperPart.bottomAnchor : swipeCards[index - 1].bottomAnchor, constant: index == 0 ? yLevelSpacing : cardYSpacing)
            ])
        }
    }
    
    func setupViewsForSecondPanel(for target: UIView) {
        numPadButton.image = UIImage(named: "Button Off")
        numPadPanel.image = UIImage(named: "numberPanel")
        numPadDeleteButton.image = UIImage(named: "Delete Button Off")
        numPadEnterButton.image = UIImage(named: "Enter Button Off")
        
        numPadButton.translatesAutoresizingMaskIntoConstraints = false
        numPadPanel.translatesAutoresizingMaskIntoConstraints = false
        numPadDeleteButton.translatesAutoresizingMaskIntoConstraints = false
        numPadEnterButton.translatesAutoresizingMaskIntoConstraints = false
        
        target.addSubview(numPadButton)
        target.addSubview(numPadPanel)
        target.addSubview(numPadDeleteButton)
        target.addSubview(numPadEnterButton)
    }
    
    
    

}
