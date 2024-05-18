//
//  bottomSheetView.swift
//  WeMap
//
//  Created by Lee Soheun on 5/15/24.
//

import Foundation
import FloatingPanel

func initialSetting(fpc: FloatingPanelController, in parent: UIViewController) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let contentVC = storyboard.instantiateViewController(withIdentifier: "homeBottomSheetViewController") as! homeBottomSheetViewController
    fpc.set(contentViewController: contentVC)
    fpc.addPanel(toParent: parent)
}

// bottom sheet 설정
func setBottomSheet(fpc: FloatingPanelController) {
    setLayout(fpc: fpc)
}

// 레이아웃 관련 세팅
func setLayout(fpc: FloatingPanelController) {
    let appearance = SurfaceAppearance()
    appearance.cornerRadius = 25.0
    fpc.surfaceView.appearance = appearance
    fpc.layout = CustomFloatingPanelLayout()
}

// content 바꾸기 (설정하기)
func setContent(add vc : UIViewController, from parent: UIViewController, by fpc: FloatingPanelController) {
    fpc.set(contentViewController: vc)
    fpc.addPanel(toParent: parent)
    fpc.move(to: .half, animated: true)
}

class CustomFloatingPanelLayout: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelLayoutAnchor(fractionalInset: 0.9, edge: .bottom, referenceGuide: .superview),
                .half: FloatingPanelLayoutAnchor(fractionalInset: 0.48, edge: .bottom, referenceGuide: .superview),
                .tip: FloatingPanelLayoutAnchor(fractionalInset: 0.15, edge: .bottom, referenceGuide: .superview)
            ]
        }
}
