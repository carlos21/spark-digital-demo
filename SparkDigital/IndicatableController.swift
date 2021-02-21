//
//  IndicatableController.swift
//  SparkDigital
//
//  Created by Carlos Duclos on 20/02/21.
//

import Foundation
import UIKit
import SnapKit

protocol IndicatableController {
    
}

extension IndicatableController where Self: UIViewController {
    
    func showIndicator(visible: IndicatorVisibility,
                       type: IndicatorType,
                       tag: Int = 20,
                       duration: TimeInterval = 0.15) {
        let containerView: UIView = type.containerView ?? view
        switch visible {
        case .show(let settings):
            guard containerView.viewWithTag(tag) == nil else { return }
            
            let indicatorView = createIndicatorView(settings: settings)
            indicatorView.tag = tag
            
            switch type {
            case .fullScreen:
                containerView.addSubviewAnimated(indicatorView, duration: duration)
                indicatorView.snp.makeConstraints { $0.edges.equalTo(0) }
                
            case .overListView(let listView):
                containerView.addSubviewAnimated(indicatorView, duration: duration)
                indicatorView.snp.makeConstraints {
                    $0.edges.equalTo(listView.snp.edges)
                }
            }
            
        case .hide:
            if let indicatorView = containerView.viewWithTag(tag) {
                indicatorView.removeFromSuperViewAnimated(duration: duration)
            }
        }
    }
    
    private func createIndicatorView(settings: IndicatorView.Settings) -> IndicatorView {
        let view = IndicatorView()
        view.image = settings.image
        view.title = settings.title
        view.message = settings.message
        view.buttonTitle = settings.buttonTitle ?? ""
        view.buttonAction = settings.buttonAction
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

enum IndicatorVisibility {
    
    case show(IndicatorView.Settings)
    case hide
}

enum IndicatorType {
    
    case fullScreen
    case overListView(UIView)
    
    var containerView: UIView? {
        switch self {
        case .fullScreen: return nil
        case .overListView(let view): return view.superview
        }
    }
}

protocol IndicatableView where Self: UIView {
    
    var title: String? { get set }
    var message: String { get set }
    var image: UIImage? { get set }
    var buttonTitle: String { get set }
}
