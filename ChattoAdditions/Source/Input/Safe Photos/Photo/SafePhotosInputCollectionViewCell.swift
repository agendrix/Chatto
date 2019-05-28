//
// Created by Mathieu Blanchette on 2019-05-28.
// Copyright (c) 2019 Agendrix. All rights reserved.
//

import UIKit

class SafePhotosInputCollectionViewCell: PhotosInputCell {

    private static let accessibilityIdentifier = "chatto.inputbar.safephotos.cell.photo"

    static let reuseIdentifier = "SafePhotosInputCollectionViewCell"

    private let overlayView = UIView()
    private let sendButton = UIButton()

    public var sendButtonText: String? {
        get { return sendButton.titleLabel?.text }
        set { sendButton.setTitle(newValue, for: UIControl.State()) }
    }

    public var sendButtonTappedHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.clipsToBounds = true

        self.imageView.contentMode = .scaleAspectFill

        self.contentView.backgroundColor = Constants.backgroundColor
        self.contentView.addSubview(self.imageView)

        setupOverlayView()
        setupSendButton()

        overlayView.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        sendButton.layer.cornerRadius = sendButton.frame.size.width / 2
        sendButton.layer.masksToBounds = true
    }

    public func setSelected(_ selected: Bool, animated: Bool = true) {
        if animated {
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.overlayView.isHidden = !selected
            })
        } else {
            self.overlayView.isHidden = !selected
        }
    }

    @objc private func sendButtonTapped() {
        sendButtonTappedHandler?()
    }

    private func setupOverlayView() {
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    private func setupSendButton() {
        sendButton.layer.borderColor = UIColor.white.cgColor
        sendButton.layer.borderWidth = 1
        sendButton.tintColor = UIColor.white

        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.setTitleColor(UIColor.white, for: UIControl.State())
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(sendButton)

        let widthConstraint = sendButton.widthAnchor.constraint(equalToConstant: 55)
        widthConstraint.priority = UILayoutPriority(999)

        let heightConstraint = sendButton.heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            widthConstraint,
            heightConstraint,
            sendButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            sendButton.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
        ])
    }
}
