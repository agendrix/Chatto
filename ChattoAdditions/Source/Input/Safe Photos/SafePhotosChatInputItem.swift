//
// Created by Mathieu Blanchette on 2019-05-16.
// Copyright (c) 2019 Agendrix. All rights reserved.
//

import UIKit
import Chatto

open class SafePhotosChatInputItem: PhotosChatInputItem {

    typealias Class = SafePhotosChatInputItem

    private var sendButtonText: String?

    lazy var safePhotosInputView: PhotosInputViewProtocol = {
        let safePhotosInputView = SafePhotosInputView(
            cameraPickerFactory: PhotosInputCameraPickerFactory(presentingViewControllerProvider: { [weak self] in self?.presentingController
            }),
            liveCameraCellPresenterFactory: LiveCameraCellPresenterFactory()
        )
        
        safePhotosInputView.delegate = self

        if let sendButtonText = self.sendButtonText {
            safePhotosInputView.sendButtonText = sendButtonText
        }

        return safePhotosInputView
    }()

    public init(
        presentingController: UIViewController?,
        tabInputButtonAppearance: TabInputButtonAppearance = PhotosChatInputItem.createDefaultButtonAppearance(),
        sendButtonText: String? = "Send"
    ) {
        super.init(presentingController: presentingController, tabInputButtonAppearance: tabInputButtonAppearance)
        self.sendButtonText = sendButtonText
    }

    override open var inputView: UIView? {
        return self.safePhotosInputView as? UIView
    }
}
