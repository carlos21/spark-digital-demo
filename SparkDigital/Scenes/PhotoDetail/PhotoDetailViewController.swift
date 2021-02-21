//
//  PhotoDetailViewController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit
import PresentationLogic
import Core

final class PhotoDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    
    var index: Int = 0
    
    var image: UIImage? {
        guard let data = viewModel.photo?.bigImageState.data else { return nil }
        return UIImage(data: data)
    }
    
    lazy var viewModel: PhotoDetailViewModel = {
        let transferService = AppContainer.shared.dataTransferService
        let downloadImageUseCase = DownloadImageUseCase(transferService: transferService)
        return PhotoDetailViewModel(downloadImageUseCase: downloadImageUseCase)
    }()
    
    // MARK: - Functions
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.download()
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.image
    }
    
    private func setupBindings() {
        viewModel.photoUpdated.delegate(to: self) { (self, photo) in
            switch photo.bigImageState {
            case .loading:
                break
                
            case .success(let data):
                self.imageView.image = UIImage(data: data)
                
            default:
                if let data = photo.thumbnailData {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
}

extension PhotoDetailViewController: InstantiableController {
    
    static func instance() -> PhotoDetailViewController {
        return R.storyboard.photoDetail.instantiateInitialViewController()!
    }
    
    static func instance(photo: PhotoVM) -> PhotoDetailViewController {
        let controller = R.storyboard.photoDetail.instantiateInitialViewController()!
        controller.viewModel.photo = photo
        return controller
    }
}
