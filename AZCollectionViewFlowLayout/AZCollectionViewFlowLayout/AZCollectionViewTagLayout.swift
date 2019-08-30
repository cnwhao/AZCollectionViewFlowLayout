//
//  UICollectionViewTagLayout.swift
//  AZCollectionViewFlowLayout
//
//  Created by wanghaohao on 2019/8/29.
//  Copyright © 2019 whao. All rights reserved.
//

import UIKit

class AZCollectionViewTagLayout: UICollectionViewLayout {
    /// 内边距
    var edgeInset:(Int) -> UIEdgeInsets = { section in
        return .zero
    }
    
    /// 行间距
    var rowSpaceHeight:(Int) -> CGFloat = { section in
        return 0.0
    }
    
    /// 列间距
    var columnSeprateWidth:(Int) -> CGFloat = { section in
        return 0.0
    }
    
    /// section头尺寸
    var sectionHeaderSize:(Int) -> CGSize = { section in
        return .zero
    }
    
    /// section脚尺寸
    var sectionFooterSize:(Int) -> CGSize = { section in
        return .zero
    }
    
    /// tag 高度
    var tagHeight:CGFloat = 30
    var tagWidth:(IndexPath) -> CGFloat = { indexPath in
        return 0
    }
    
    /// section装饰视图
    var sectionDecorationView:(_ section:Int) -> (viewClass: AnyClass?, elementKind: String)? = { section in
        return nil
    }
    
    /// section中第一行y偏移量
    private var row0Off:CGFloat = 0.0
    /// 当前x偏移量
    private var currentOffX:CGFloat = 0.0
    /// 当前行有多少个tag
    private var currentRowTagCount:Int = 0
    /// 当前y偏移量
    private var currentOffMaxY:CGFloat = 0.0
    
    /// 缓存布局属性数组
    private var attributesArray = [UICollectionViewLayoutAttributes]()
    
    /// 准备布局
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        
        // 注册装饰视图
        for section in 0..<collectionView.numberOfSections {
            if let decorationViewInfo = sectionDecorationView(section) {
                self.register(decorationViewInfo.viewClass, forDecorationViewOfKind: decorationViewInfo.elementKind)
            }
        }
        
        //清除缓存
        currentOffX = 0
        currentOffMaxY = 0
        attributesArray.removeAll()
        // 创建新的布局属性
        for section in 0..<collectionView.numberOfSections {
            // 头部视图属性
            if let attibutes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)) {
                attributesArray.append(attibutes)
            }
            // collectionviewcell视图属性
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                if let attributes = layoutAttributesForItem(at: IndexPath(item: row, section: section)) {
                    attributesArray.append(attributes)
                }
            }
            if let decorationViewInfo = sectionDecorationView(section) {
                // 装饰视图属性，一定要放在cell后
                if let attibutes = layoutAttributesForDecorationView(ofKind: decorationViewInfo.elementKind, at: IndexPath(item: 0, section: section)) {
                    attibutes.zIndex = -1
                    attributesArray.append(attibutes)
                }
            }
            // 脚部视图属性
            if let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section)) {
                attributesArray.append(attributes)
            }
        }
    }
    
    /// 返回布局属性数组
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesArray
//        return attributesArray.filter { $0.frame.intersects(rect) }
    }
    
    /// 返回头尾布局属性(追加视图)
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        attributes.frame = self.verticalSupplementaryViewFrame(ofKind: elementKind, at: indexPath)
        return attributes
    }
    
    /// 返回装饰视图布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        
        attributes.frame = self.verticalDecorationViewFrame(ofKind: elementKind, at: indexPath)
        return attributes
    }
    
    /// 返回collectionviewcell布局属性
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = self.verticalItemFrame(with: indexPath)
        return attributes
    }
    
    /// cotentsize
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }
        var contentSize = CGSize(width: collectionView.frame.width - 1, height: currentOffMaxY)
        if contentSize.height < collectionView.frame.size.height {
            contentSize.height = collectionView.frame.size.height + 1
        }
        return contentSize
    }
}

extension AZCollectionViewTagLayout {
    private func verticalDecorationViewFrame(ofKind elementKind:String, at indexPath:IndexPath) -> CGRect {
        let y = currentOffMaxY
        // 不使用内边距
        let x:CGFloat = 0//edgeInset(indexPath.section).left
        let size = collectionView!.frame.size
        let rect = CGRect(x: x, y: row0Off, width: size.width, height: y - row0Off)
        return rect
    }
    
    private func verticalSupplementaryViewFrame(ofKind elementKind:String, at indexPath:IndexPath) -> CGRect {
        var y = currentOffMaxY
        if elementKind == UICollectionView.elementKindSectionHeader {
            y += edgeInset(indexPath.section).top
        }
        
        let x:CGFloat = 0//edgeInset(indexPath.section).left
        var size:CGSize = .zero
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            size = sectionHeaderSize(indexPath.section)
        default:
            size = sectionFooterSize(indexPath.section)
        }
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        var edgeInsetBottom:CGFloat = 0
        if elementKind == UICollectionView.elementKindSectionFooter {
            edgeInsetBottom = edgeInset(indexPath.section).bottom
        }
        currentOffMaxY = rect.maxY + edgeInsetBottom
        return rect
    }
    
    private func verticalItemFrame(with indexPath:IndexPath) -> CGRect {
        if indexPath.row == 0 {
            row0Off = currentOffMaxY
            currentOffMaxY += tagHeight
            currentRowTagCount = 0
        }
        let itemWidth:CGFloat = tagWidth(indexPath)
        var x:CGFloat = edgeInset(indexPath.section).left + CGFloat( currentRowTagCount) * (itemWidth + columnSeprateWidth(indexPath.section))
        
        if x + itemWidth > collectionView!.frame.size.width - edgeInset(indexPath.section).right {
            currentRowTagCount = 0
            x = edgeInset(indexPath.section).left
            currentOffMaxY = currentOffMaxY + (rowSpaceHeight(indexPath.section) + tagHeight)
        }
        let y = currentOffMaxY - tagHeight
        let rect = CGRect(x: x, y: y, width: itemWidth, height: tagHeight)
        currentRowTagCount += 1
        return rect
    }
}
