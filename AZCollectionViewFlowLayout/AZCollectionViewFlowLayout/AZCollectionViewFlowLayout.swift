//
//  AZCollectionViewFlowLayout.swift
//  AZCollectionViewFlowLayout
//
//  Created by wanghaohao on 2019/8/26.
//  Copyright © 2019 whao. All rights reserved.
//

import UIKit

enum AZWaterFlowStyle {
    case horizontal
    case vertical
}

class AZCollectionViewFlowLayout: UICollectionViewLayout {
    /// 瀑布流样式
    var flowStyle:AZWaterFlowStyle = .vertical
    
    /// 瀑布流条数
    var flowCount:(Int) -> Int = { section in
        return 1
    }
    
    /// 内边距
    var edgeInset:(Int) -> UIEdgeInsets = { section in
        return .zero
    }
    
    /// 行间距
    var rowSpaceHeight:(Int) -> CGFloat = { section in
        return 0.0
    }
    
    /// 流（列）间距
    var flowSeprateWidth:(Int) -> CGFloat = { section in
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
    
    /// 每个collectionviewcell的尺寸
    var itemSize:(IndexPath) -> CGSize = { indexPath in
        return .zero
    }
    
    /// section装饰视图
    var sectionDecorationView:(_ section:Int) -> (viewClass: AnyClass?, elementKind: String)? = { section in
        return nil
    }
    
    /// row0 位置
    private var row0Off:CGFloat = 0.0
    
    private var flowBottomPoint = [CGFloat]()
    
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
        var fCount = 1
        for section in 0..<collectionView.numberOfSections {
            fCount = max(fCount, flowCount(section))
        }
        flowBottomPoint = Array(repeating: 0, count: fCount)
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
        return attributesArray.filter { $0.frame.intersects(rect) }
    }
    
    /// 返回头尾布局属性(追加视图)
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        if flowStyle == .horizontal {
            attributes.frame = self.horizontalSupplementaryViewFrame(ofKind: elementKind, at: indexPath)
        } else {
            attributes.frame = self.verticalSupplementaryViewFrame(ofKind: elementKind, at: indexPath)
        }
        return attributes
    }
    
    /// 返回装饰视图布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        
        if flowStyle == .horizontal {
            attributes.frame = self.horizontalDecorationViewFrame(ofKind: elementKind, at: indexPath)
        } else {
            attributes.frame = self.verticalDecorationViewFrame(ofKind: elementKind, at: indexPath)
        }
        return attributes
    }
    
    /// 返回collectionviewcell布局属性
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if flowStyle == .horizontal {
            attributes.frame = self.horizontalItemFrame(with: indexPath)
        } else {
            attributes.frame = self.verticalItemFrame(with: indexPath)
        }
        return attributes
    }
    
    /// cotentsize
    override var collectionViewContentSize: CGSize {
        guard let maxColumnOff = flowBottomPoint.first, let collectionView = collectionView else {
            return .zero
        }
        
        if flowStyle == .horizontal {
            var contentSize = CGSize(width: maxColumnOff + edgeInset(collectionView.numberOfSections - 1).right, height: collectionView.frame.height - 1)
            if contentSize.width < collectionView.frame.size.width {
                contentSize.width = collectionView.frame.size.width + 1
            }
            return contentSize
        } else {
            var contentSize = CGSize(width: collectionView.frame.width - 1, height: maxColumnOff + edgeInset(collectionView.numberOfSections - 1).bottom)
            if contentSize.height < collectionView.frame.size.height {
                contentSize.height = collectionView.frame.size.height + 1
            }
            return contentSize
        }
    }
}

extension AZCollectionViewFlowLayout {
    private func verticalDecorationViewFrame(ofKind elementKind:String, at indexPath:IndexPath) -> CGRect {
        //最大point y
        let y = flowBottomPoint.prefix(flowCount(indexPath.section)).sorted().last!
        // 不使用内边距
        let x:CGFloat = 0//edgeInset(indexPath.section).left
        let size = collectionView!.frame.size
        let rect = CGRect(x: x, y: row0Off, width: size.width, height: y - row0Off)
        return rect
    }
    
    private func horizontalDecorationViewFrame(ofKind elementKind:String, at indexPath:IndexPath) -> CGRect {
        //最大point x
        let x = flowBottomPoint.prefix(flowCount(indexPath.section)).sorted().last!
        // 不使用内边距
        let y:CGFloat = 0//edgeInset(indexPath.section).top
        let size = collectionView!.frame.size
        let rect = CGRect(x: row0Off, y: y, width: x - row0Off, height: size.height)
        return rect
    }
    
    private func verticalSupplementaryViewFrame(ofKind elementKind:String, at indexPath:IndexPath) -> CGRect {
        //最大point y
        var y = flowBottomPoint.prefix(flowCount(indexPath.section)).sorted().last!
        if elementKind == UICollectionView.elementKindSectionHeader {
            y += edgeInset(indexPath.section).top
        }
        // headerview、footerview不使用内边距
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
        flowBottomPoint = Array(repeating: rect.maxY + edgeInsetBottom, count: flowBottomPoint.count)
        return rect
    }
    
    private func horizontalSupplementaryViewFrame(ofKind elementKind:String, at indexPath:IndexPath) -> CGRect {
        //最大point x
        var x = flowBottomPoint.prefix(flowCount(indexPath.section)).sorted().last!
        if elementKind == UICollectionView.elementKindSectionHeader {
            x += edgeInset(indexPath.section).left
        }
        // headerview、footerview不使用内边距
        let y:CGFloat = 0//edgeInset(indexPath.section).top
        var size:CGSize = .zero
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            size = sectionHeaderSize(indexPath.section)
        default:
            size = sectionFooterSize(indexPath.section)
        }
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        var edgeInsetRight:CGFloat = 0
        if elementKind == UICollectionView.elementKindSectionFooter {
            edgeInsetRight = edgeInset(indexPath.section).right
        }
        flowBottomPoint = Array(repeating: rect.maxX + edgeInsetRight, count: flowBottomPoint.count)
        return rect
    }
    
    private func verticalItemFrame(with indexPath:IndexPath) -> CGRect {
        //最小point y
        var y = flowBottomPoint.prefix(flowCount(indexPath.section)).sorted().first!
        //接下来要添加cell 的流下标
        let flowIndex = flowBottomPoint.firstIndex(of: y) ?? 0
        
        if indexPath.row == 0 {
            row0Off = y
        }
        if y != row0Off { // section 不是第一行
            y += rowSpaceHeight(indexPath.section)
        }
        var size:CGSize = itemSize(indexPath)
        if collectionView != nil && size.width > 0 {
            let flowWidth:CGFloat = (collectionView!.frame.size.width - edgeInset(indexPath.section).left - edgeInset(indexPath.section).right - flowSeprateWidth(indexPath.section) * CGFloat(flowCount(indexPath.section) - 1)) / CGFloat(flowCount(indexPath.section))
            let flowHeight = flowWidth / size.width * size.height
            size = CGSize(width: flowWidth, height: flowHeight)
        }
        let x:CGFloat = edgeInset(indexPath.section).left + CGFloat(flowIndex) * (size.width + flowSeprateWidth(indexPath.section))
        
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        // 更新最短flow高度
        flowBottomPoint[flowIndex] = rect.maxY
        return rect
    }
    
    private func horizontalItemFrame(with indexPath:IndexPath) -> CGRect {
        //最小point x
        var x = flowBottomPoint.prefix(flowCount(indexPath.section)).sorted().first!
        //接下来要添加cell 的流下标
        let flowIndex = flowBottomPoint.firstIndex(of: x) ?? 0
        
        if indexPath.row == 0 {
            row0Off = x
        }
        if x != row0Off { // section 不是第一列
            x += flowSeprateWidth(indexPath.section)
        }
        var size:CGSize = itemSize(indexPath)
        if collectionView != nil && size.width > 0 {
            let flowHeight:CGFloat = (collectionView!.frame.size.height - edgeInset(indexPath.section).top - edgeInset(indexPath.section).bottom - rowSpaceHeight(indexPath.section) * CGFloat(flowCount(indexPath.section) - 1)) / CGFloat(flowCount(indexPath.section))
            let flowWidth = flowHeight / size.height * size.width
            size = CGSize(width: flowWidth, height: flowHeight)
        }
        let y:CGFloat = edgeInset(indexPath.section).top + CGFloat(flowIndex) * (size.height + rowSpaceHeight(indexPath.section))
        
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        // 更新最短flow高度
        flowBottomPoint[flowIndex] = rect.maxX
        return rect
    }
}
