import UIKit

internal class PlayerNameView: UITextField {
    
    internal var username: String
    
    init(username: String) {
        self.username = username
        super.init(frame: .zero)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField() {
        placeholder = "enter name here"
        text = username
        textAlignment = .left
        font = UIFont(name: "RobotoMono-Medium", size: 14)
        textColor = .black
        backgroundColor = .clear
        borderStyle = .none
        tintColor = .black
        
        let backgroundTextField = UIImageView(image: UIImage(named: "text_field_player_name"))
        backgroundTextField.contentMode = .scaleToFill
        backgroundTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundTextField)
        sendSubviewToBack(backgroundTextField)
        
        NSLayoutConstraint.activate([
            backgroundTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundTextField.topAnchor.constraint(equalTo: topAnchor),
            backgroundTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        leftView = paddingView
        leftViewMode = .always
        rightView = paddingView
        rightViewMode = .always
    }
    
}
