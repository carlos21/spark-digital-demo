//
//  IndicatorView.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit

class IndicatorView: NibDesignableView, IndicatableView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            updateVisibility()
        }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            updateVisibility()
        }
    }
    
    var message: String {
        get { return messageLabel.text ?? "" }
        set { messageLabel.text = newValue }
    }
    
    var buttonTitle: String {
        get { return button.title(for: .normal) ?? "" }
        set {
            button.setTitle(newValue, for: .normal)
            button.isHidden = newValue.isEmpty
        }
    }
    
    var buttonAction: (() -> Void)?
    
    // MARK: - Initialize
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        updateVisibility()
    }
    
    private func updateVisibility() {
        titleLabel.isHidden = title == nil
        imageView.isHidden = image == nil
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        buttonAction?()
    }
}

extension IndicatorView {
    
    class Settings {
        
        let title: String?
        let message: String
        let image: UIImage?
        let buttonTitle: String?
        let buttonAction: (() -> Void)?
        
        internal init(title: String?,
                      message: String,
                      image: UIImage? = nil,
                      buttonTitle: String? = nil,
                      buttonAction: (() -> Void)? = nil) {
            self.title = title
            self.message = message
            self.image = image
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
    }
}
