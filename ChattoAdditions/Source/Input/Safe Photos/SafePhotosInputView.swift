//
// Created by Mathieu Blanchette on 2019-05-16.
// Copyright (c) 2019 Agendrix. All rights reserved.
//

import UIKit
import Photos
import Chatto

open class SafePhotosInputView: PhotosInputView {

    public var sendButtonText = "Send"

    private var selectedIndexPath: Int? = nil

    override open func configureCollectionView() {
        super.configureCollectionView()
        self.collectionViewLayout = SafePhotosInputCollectionViewLayout()
    }

    override func replacePlaceholderItemsWithPhotoItems() {
        let photosDataProvider = PhotosInputDataProvider()
        photosDataProvider.prepare { [weak self] in
            guard let sSelf = self else { return }

            sSelf.collectionViewQueue.addTask { [weak self] (completion) in
                guard let sSelf = self else { return }

                let newDataProvider = PhotosInputWithPlaceholdersDataProvider(photosDataProvider: photosDataProvider, placeholdersDataProvider: PhotosInputPlaceholderDataProvider())
                newDataProvider.delegate = sSelf
                sSelf.dataProvider = newDataProvider
                sSelf.cellProvider = SafePhotosInputCellProvider(collectionView: sSelf.collectionView, dataProvider: newDataProvider)
                sSelf.collectionView.reloadData()
                DispatchQueue.main.async(execute: completion)
            }
        }
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if indexPath.item == Constants.liveCameraItemIndex {
            cell = self.liveCameraPresenter.dequeueCell(collectionView: collectionView, indexPath: indexPath)
        } else {
            cell = self.cellProvider.cellForItem(at: indexPath)

            if let safePhotosCell = cell as? SafePhotosInputCollectionViewCell {

                safePhotosCell.setSelected(indexPath.row == selectedIndexPath)

                safePhotosCell.sendButtonText = sendButtonText

                safePhotosCell.sendButtonTappedHandler = { [weak self] in
                    guard let self = self else { return }

                    self.selectedIndexPath = nil
                    safePhotosCell.setSelected(false)

                    let request = self.dataProvider.requestFullImage(at: indexPath.item - 1, progressHandler: nil, completion: { [weak self] result in
                        guard let sSelf = self, let image = result.image else { return }
                        sSelf.delegate?.inputView(sSelf, didSelectImage: image, source: .gallery)
                    })
                    self.cellProvider.configureFullImageLoadingIndicator(at: indexPath, request: request)
                }
            }
        }
        return cell
    }

    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == Constants.liveCameraItemIndex {
            if self.cameraAuthorizationStatus != .authorized {
                self.delegate?.inputViewDidRequestCameraPermission(self)
            } else {
                self.liveCameraPresenter.cameraPickerWillAppear()
                self.cameraPicker.presentCameraPicker(onImageTaken: { [weak self] (result) in
                    guard let sSelf = self else { return }
                    if let result = result {
                        sSelf.delegate?.inputView(sSelf, didSelectImage: result.image, source: .camera(result.cameraType))
                    }
                }, onCameraPickerDismissed: { [weak self] in
                    self?.liveCameraPresenter.cameraPickerDidDisappear()
                })
            }
        } else {
            if self.photoLibraryAuthorizationStatus != .authorized {
                self.delegate?.inputViewDidRequestPhotoLibraryPermission(self)
            } else {
                if let cell = collectionView.cellForItem(at: indexPath) as? SafePhotosInputCollectionViewCell {
                    if let selectedIndex = selectedIndexPath, let selectedCell = collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as? SafePhotosInputCollectionViewCell  {
                        selectedCell.setSelected(false)
                    }

                    selectedIndexPath = indexPath.row
                    cell.setSelected(true)
                }
            }
        }
    }
}

private class SafePhotosInputCollectionViewLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != self.collectionView?.bounds.width
    }
}

