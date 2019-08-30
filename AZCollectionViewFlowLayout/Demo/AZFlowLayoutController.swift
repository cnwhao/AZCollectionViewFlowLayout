//
//  AZFlowLayoutController.swift
//  AZCollectionViewFlowLayout
//
//  Created by wanghaohao on 2019/8/29.
//  Copyright © 2019 whao. All rights reserved.
//

import UIKit

class AZFlowLayoutController: UIViewController {
    private var flowStyle:AZWaterFlowStyle = .vertical
    private let screenWidth = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    private let cellIdentify:String = "cellIdentify"
    private let headerIdentify:String = "headerIdentify"
    private lazy var collectionView:UICollectionView = {
        
        let flowLayout = flowStyle == .vertical ? self.verticalFlowLayout() : self.horizontalFlowLayout()
        flowLayout.sectionDecorationView = { section in
            if section == 1 {
                return (AZCollectionDecorateReusableView.self, "AZCollectionDecorateReusableView")
            }
            return nil
        }
//        let flowLayout = self.collectionViewFlowLayout()
        
        let clv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        clv.backgroundColor = .white
        clv.dataSource = self
        clv.delegate = self
        
        clv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentify)
        clv.register(AZCollectionSectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentify)
        clv.register(AZCollectionSectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: headerIdentify)
        
        //此处给其增加长按手势，用此手势触发cell移动效果
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlelongGesture(longGesture:)))
        clv.addGestureRecognizer(longGesture)
        return clv
    }()
    
    @objc private func handlelongGesture(longGesture:UILongPressGestureRecognizer) {
        switch longGesture.state {
        case .began:
            let indexPath = collectionView.indexPathForItem(at: longGesture.location(in: collectionView))
            if indexPath == nil {break}
            collectionView.beginInteractiveMovementForItem(at: indexPath!)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(longGesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    init(flowStyle:AZWaterFlowStyle) {
        super.init(nibName: nil, bundle: nil)
        self.flowStyle = flowStyle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = .white
        self.view.addSubview(self.collectionView)
        var rect = self.view.bounds
        rect.origin.y = 120
        rect.size.height -= rect.origin.y
        self.collectionView.frame = rect
    }
    
    private func horizontalFlowLayout() -> AZCollectionViewFlowLayout {
        let flowLayout = AZCollectionViewFlowLayout()
        flowLayout.flowStyle = AZWaterFlowStyle.horizontal
        flowLayout.edgeInset = { section in
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        flowLayout.rowSpaceHeight = { section in
            return 10
        }
        flowLayout.flowSeprateWidth = { section in
            return 10
        }
        flowLayout.sectionHeaderSize = {section in
            return CGSize(width: 30, height: self.screenHeight)
        }
        flowLayout.sectionFooterSize = {section in
            return CGSize(width: 20, height: self.screenHeight)
        }
        flowLayout.itemSize = { indexPath in
            if indexPath.section == 0 {
                return CGSize(width: 100, height: 100 * (1.0 + CGFloat(indexPath.row) / 10.0))
            }
            return CGSize(width: 100, height: 150)
        }
        
        flowLayout.flowCount = { section in
            if section == 1 {
                return 1
            }
            return 2
        }
        return flowLayout
    }
    
    private func collectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: 100, height: 150)
        return flowLayout
    }
    
    private func verticalFlowLayout() -> AZCollectionViewFlowLayout {
        let flowLayout = AZCollectionViewFlowLayout()
        flowLayout.edgeInset = { section in
            if section == 1{
                return UIEdgeInsets(top: 10, left: CGFloat(section + 1) * 30, bottom: 10, right: CGFloat(section + 1) * 30)
            }
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        flowLayout.rowSpaceHeight = { section in
            return 10
        }
        flowLayout.flowSeprateWidth = { section in
            return 10
        }
        flowLayout.sectionHeaderSize = {section in
            return CGSize(width: self.screenWidth, height: 30)
        }
        flowLayout.sectionFooterSize = {section in
            return CGSize(width: self.screenWidth, height: 20)
        }
        flowLayout.itemSize = { indexPath in
            if indexPath.section == 0 {
                return CGSize(width: 100, height: 100 * (1.0 + CGFloat(indexPath.row) / 10.0))
            }
            return CGSize(width: 100, height: 150)
        }
        
        flowLayout.flowCount = { section in
            if section == 1 {
                return 1
            }
            return 2
        }
        return flowLayout
    }

}

extension AZFlowLayoutController:UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentify, for: indexPath)
        cell.backgroundColor = indexPath.row % 2 == 0 ? .red : .orange
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentify, for: indexPath)
        view.backgroundColor = kind == UICollectionView.elementKindSectionHeader ? .green : .blue
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("from = \(sourceIndexPath.section), \(sourceIndexPath.row)  to = \(destinationIndexPath.section), \(destinationIndexPath.row)")
    }
}

class AZCollectionSectionHeaderReusableView: UICollectionReusableView {
    
}

class AZCollectionDecorateReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
