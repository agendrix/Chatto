//
// Created by Mathieu Blanchette on 2019-05-16.
// Copyright (c) 2019 Agendrix. All rights reserved.
//

open class SafePhotosChatInputItem: PhotosChatInputItem {

    typealias Class = SafePhotosChatInputItem

    private var sendButtonText: String?

    lazy var safePhotosInputView: PhotosInputViewProtocol = {
        let safePhotosInputView = SafePhotosInputView(presentingController: self.presentingController, appearance: self.inputViewAppearance)
        safePhotosInputView.delegate = self

        if let sendButtonText = self.sendButtonText {
            safePhotosInputView.sendButtonText = sendButtonText
        }

        return safePhotosInputView
    }()

    public init(presentingController: UIViewController?,
                tabInputButtonAppearance: TabInputButtonAppearance = PhotosChatInputItem.createDefaultButtonAppearance(),
                inputViewAppearance: PhotosInputViewAppearance = PhotosChatInputItem.createDefaultInputViewAppearance(),
                sendButtonText: String? = "Send") {
        super.init(presentingController: presentingController, tabInputButtonAppearance: tabInputButtonAppearance, inputViewAppearance: inputViewAppearance)
        self.sendButtonText = sendButtonText
    }

    override open var inputView: UIView? {
        return self.safePhotosInputView as? UIView
    }
}