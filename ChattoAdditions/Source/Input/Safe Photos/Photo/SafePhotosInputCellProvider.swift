//
// Created by Mathieu Blanchette on 2019-05-28.
//

import UIKit

class SafePhotosInputCellProvider: PhotosInputCellProvider {

    override init(collectionView: UICollectionView, dataProvider: PhotosInputDataProviderProtocol) {
        super.init(collectionView: collectionView, dataProvider: dataProvider)
        self.collectionView.register(SafePhotosInputCollectionViewCell.self, forCellWithReuseIdentifier: SafePhotosInputCollectionViewCell.reuseIdentifier)
    }

    override func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: SafePhotosInputCollectionViewCell.reuseIdentifier, for: indexPath) as! SafePhotosInputCollectionViewCell
        self.configureCell(cell, at: indexPath)
        return cell
    }

    override func configureFullImageLoadingIndicator(at indexPath: IndexPath, request: PhotosInputDataProviderImageRequestProtocol) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? SafePhotosInputCollectionViewCell else { return }
        self.configureCellForFullImageLoadingIfNeeded(cell, request: request)
    }

    private func configureCell(_ cell: SafePhotosInputCollectionViewCell, at indexPath: IndexPath) {
        if let request = self.previewRequests[cell.hash] {
            self.previewRequests[cell.hash] = nil
            request.cancel()
        }
        self.fullImageRequests[cell.hash] = nil
        let index = indexPath.item - 1
        let targetSize = cell.bounds.size
        var imageProvidedSynchronously = true
        var requestId: Int32 = -1
        let request = self.dataProvider.requestPreviewImage(at: index, targetSize: targetSize) { [weak self, weak cell] result in
            guard let sSelf = self, let sCell = cell else { return }
            // We can get here even afer calling cancelPreviewImageRequest (looks liek a race condition in PHImageManager)
            // Also, according to PHImageManager's documentation, this block can be called several times: we may receive an image with a low quality and then receive an update with a better one
            // This can also be called before returning from requestPreviewImage (synchronously) if the image is cached by PHImageManager
            let imageIsForThisCell = imageProvidedSynchronously || sSelf.previewRequests[sCell.hash]?.requestId == requestId
            if imageIsForThisCell {
                sCell.image = result.image
                sSelf.previewRequests[sCell.hash] = nil
            }
        }
        requestId = request.requestId
        imageProvidedSynchronously = false
        self.previewRequests[cell.hash] = request
        if let fullImageRequest = self.dataProvider.fullImageRequest(at: index) {
            self.configureCellForFullImageLoadingIfNeeded(cell, request: fullImageRequest)
        }
    }

    private func configureCellForFullImageLoadingIfNeeded(_ cell: SafePhotosInputCollectionViewCell, request: PhotosInputDataProviderImageRequestProtocol) {
        guard request.progress < 1 else { return }
        cell.showProgressView()
        cell.updateProgress(CGFloat(request.progress))
        request.observeProgress(with: { [weak self, weak cell, weak request] progress in
            guard let sSelf = self, let sCell = cell, sSelf.fullImageRequests[sCell.hash] === request else { return }
            cell?.updateProgress(CGFloat(progress))
        }, completion: { [weak self, weak cell, weak request] _ in
            guard let sSelf = self, let sCell = cell, sSelf.fullImageRequests[sCell.hash] === request else { return }
            sCell.hideProgressView()
            sSelf.fullImageRequests[sCell.hash] = nil
        })
        self.fullImageRequests[cell.hash] = request
    }
}
