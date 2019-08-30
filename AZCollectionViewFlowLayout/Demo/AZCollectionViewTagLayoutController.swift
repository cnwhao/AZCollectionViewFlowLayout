//
//  AZCollectionViewTagLayoutController.swift
//  AZCollectionViewFlowLayout
//
//  Created by wanghaohao on 2019/8/29.
//  Copyright © 2019 whao. All rights reserved.
//

import UIKit

class AZCollectionViewTagLayoutController: UIViewController {
    private let screenWidth = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    private let cellIdentify:String = "cellIdentify"
    private let headerIdentify:String = "headerIdentify"
    private lazy var collectionView:UICollectionView = {
        
        let flowLayout = self.tagFlowLayout()
        flowLayout.sectionDecorationView = { section in
            if section == 1 {
                return (AZCollectionDecorateReusableView.self, "AZCollectionDecorateReusableView")
            }
            return nil
        }
        let clv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        clv.backgroundColor = .white
        clv.dataSource = self
        clv.delegate = self
        
        clv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentify)
        clv.register(AZCollectionSectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentify)
        clv.register(AZCollectionSectionHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: headerIdentify)
        return clv
    }()
    
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
    
    private func tagFlowLayout() -> AZCollectionViewTagLayout {
        let flowLayout = AZCollectionViewTagLayout()
        flowLayout.edgeInset = { section in
            return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        }
        flowLayout.rowSpaceHeight = { section in
            return 10
        }
        flowLayout.columnSeprateWidth = { section in
            return 10
        }
        flowLayout.sectionHeaderSize = {section in
            return CGSize(width: self.screenWidth, height: 30)
        }
        flowLayout.sectionFooterSize = {section in
            return CGSize(width: self.screenWidth, height: 20)
        }
        flowLayout.tagWidth = { indexPath in
            return 30 + CGFloat(indexPath.row + indexPath.row * indexPath.section) / 2.0
        }
        return flowLayout
    }
}

extension AZCollectionViewTagLayoutController:UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
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
}
