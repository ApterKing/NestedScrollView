//
//  NestedSlidingViewController.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/7.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit
import MJRefresh
import RxSwift
import RxCocoa

enum NestedSlidingType: Int {
    case singleTabNotFillScreen = 0    // 单个tab数据未填充满屏幕
    case singleTabFillScreenNotFillContentSize  // 单个tab数据填充满屏幕，未填充满外层ScrollView contentSize
    case single // 上述两种情况外的单个tab情况
    case multiTabPartFill // 多个tab部分数据填充屏幕，部分未填充
    case multiTab   // 上述情况外的其他多个tab情况
    case multiTabOtherHeaderView  // 包含其他更多情况
}

/// MARK: 抛出一个实现思路，仅从更加复杂的业务逻辑中挑选出部分的实现方式
class NestedSlidingViewController: UIViewController {
    
    fileprivate let disposeBag = DisposeBag()
    
    var type: NestedSlidingType = .singleTabNotFillScreen
    
    /// MARK: 这里的headerView 你可以自定义更加复杂的界面，比如在里面添加各种水平滑动的scrollView
    private var headerView: HeaderView = {
        let header = HeaderView.instance!
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: HeaderView.defaultHeight)
        return header
    }()
    
    private var otherView: OtherView = {
        let other = OtherView.instance!
        other.frame = CGRect(x: 0, y: HeaderView.defaultHeight, width: UIScreen.width, height: OtherView.defaultHeight)
        return other
    }()
    
    private var segmentView: SegmentView = {
        let segment = SegmentView.instance!
        segment.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 40)
        return segment
    }()
    
    /// 最外层 (主要用于下拉刷新，如果项目中没有也可以用View替代）
    private let outterScrollView = UIScrollView(frame: CGRect.zero)
    private var isRefreshing = false
    
    /// 左右切换
    private let pageScrollView = UIScrollView(frame: CGRect.zero)
    private var segmentChildVCs: [NestedSlidingChildViewController] = []
    private var curSegmentChildVC: NestedSlidingChildViewController?
    private var curPageIndex = 0
    
    /// 模拟滑动、回弹
    private var panGesture: UIPanGestureRecognizer!
    private var animator: UIDynamicAnimator!
    private var dynamicItem: RubberDynamicItem!
    private var decelerationBehavior: UIDynamicBehavior?   // 滑动模拟
    private var springBehavior: UIAttachmentBehavior?  // 回弹模拟
    private var isVertical = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

/// MARK: UI
extension NestedSlidingViewController {
    
    fileprivate func _initUI() {
        view.backgroundColor = UIColor.white

        outterScrollView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - UIScreen.homeIndicatorMoreHeight)
        outterScrollView.isScrollEnabled = false   // 禁用滑动2
        outterScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        outterScrollView.showsVerticalScrollIndicator = false
        if #available(iOS 11, *) {
            outterScrollView.contentInsetAdjustmentBehavior = .never
        }
        outterScrollView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: nil)  // 不要使用MJ的刷新逻辑，用自己的实现，仅改变头部的状态即可
        view.addSubview(outterScrollView)
        
        headerView.height = HeaderView.defaultHeight
        outterScrollView.addSubview(headerView)
        
        /// 包含其他复杂情况
        if type == .multiTabOtherHeaderView {
            otherView.height = OtherView.defaultHeight
            otherView.isHidden = false
        } else {
            otherView.height = 0
            otherView.isHidden = true
        }
        outterScrollView.insertSubview(otherView, belowSubview: headerView)

        segmentView.y = otherView.y + otherView.height
        if type == .single || type == .singleTabFillScreenNotFillContentSize || type == .singleTabNotFillScreen {
            segmentView.height = 0
            segmentView.isHidden = true
        } else {
            segmentView.height = 40
            segmentView.isHidden = false
        }
        outterScrollView.insertSubview(segmentView, belowSubview: otherView)

        pageScrollView.frame = CGRect(x: 0, y: segmentView.y + segmentView.height, width: view.width, height: outterScrollView.height - UIScreen.naviBarHeight - segmentView.height)
        pageScrollView.isPagingEnabled = true
        pageScrollView.delegate = self
        pageScrollView.bounces = false
        outterScrollView.insertSubview(pageScrollView, belowSubview: segmentView)
        outterScrollView.contentSize = CGSize(width: UIScreen.width, height: pageScrollView.y + pageScrollView.height)

        // 由于没有网络请求，这里主要用于模拟业务逻辑存在的复杂情况, 你可以为childVC添加加载更多
        switch type {
        case .singleTabNotFillScreen:
            segmentChildVCs.append(_childVC(5))
        case .singleTabFillScreenNotFillContentSize:
            segmentChildVCs.append(_childVC(7))
        case .single:
            segmentChildVCs.append(_childVC(20))
        case .multiTabPartFill:
            segmentChildVCs.append(_childVC(5))
            segmentChildVCs.append(_childVC(20))
            segmentChildVCs.append(_childVC(8))
            segmentChildVCs.append(_childVC(6))
        default:
            segmentChildVCs.append(_childVC(20))
            segmentChildVCs.append(_childVC(20))
            segmentChildVCs.append(_childVC(20))
            segmentChildVCs.append(_childVC(20))
        }
        for (index, childVC) in segmentChildVCs.enumerated() {
            addChildViewController(childVC)
            pageScrollView.addSubview(childVC.view)
            childVC.view.frame = CGRect(x: CGFloat(index) * pageScrollView.width, y: 0, width: pageScrollView.width, height: pageScrollView.height)
            childVC.tableView.isScrollEnabled = false  // 所有tableView禁用滑动
            childVC.didMove(toParentViewController: self)
            segmentChildVCs.append(childVC)
        }
        pageScrollView.contentSize = CGSize(width: CGFloat(segmentChildVCs.count) * pageScrollView.width, height: pageScrollView.height)
        _resetCurrentSegmentVC(index: 0)

        headerView.closeButton.rx.controlEvent(UIControlEvents.touchUpInside)
            .subscribe { [weak self] (_) in
                self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        /// 个人喜欢使用RxSwift，这里你可以改写为iOS自己的kvo
        outterScrollView.rx.observeWeakly(CGPoint.self, "contentOffset").skip(1)
            .subscribe { [weak self] (event) in
                guard case .next(_) = event, let weakSelf = self else { return }
                weakSelf._didChangeOffset(weakSelf.outterScrollView)
            }.disposed(by: disposeBag)
        
        
        /// 添加手势，使得整个View响应事件
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        panGesture = gesture
        animator = UIDynamicAnimator(referenceView: view)
        dynamicItem = RubberDynamicItem()
    }
    
    fileprivate func _childVC(_ rows: Int) -> NestedSlidingChildViewController {
        let vc = NestedSlidingChildViewController()
        vc.numberOfRowInSection = rows
        return vc
    }
    
    private func _resetCurrentSegmentVC(index: Int) {
        guard segmentChildVCs.count != 0 && index < segmentChildVCs.count else { return }
        curPageIndex = index
        curSegmentChildVC = segmentChildVCs[index]
    }
}

// 处理在滑动过程中的各种UI改变
extension NestedSlidingViewController {
    
    // 模拟刷新
    func _refresh() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] () in
            guard let weakSelf = self else {return}
            weakSelf.isRefreshing = false
            weakSelf.outterScrollView.mj_header.state = MJRefreshState.pulling
            
            // 将outterScrollView的contentOffset该变回CGPoint.zero
            weakSelf._springScrollViewContentOffset(weakSelf.outterScrollView, CGPoint.zero)
        }
    }
    
    func _didChangeOffset(_ scrollView: UIScrollView) {
        let minY: CGFloat = UIScreen.naviBarHeight
        // 关闭刷新，当然这里你还需要处理更加复杂的网络
        if isRefreshing && scrollView.contentOffset.y >= -scrollView.mj_header.height / 2.0 {
            isRefreshing = false
            scrollView.mj_header.state = MJRefreshState.pulling
        }
        if scrollView.contentOffset.y < 0 {
            /// 开始刷新数据
            if scrollView.contentOffset.y < -scrollView.mj_header.height - UIScreen.statusBarMoreHeight - 20 && !isRefreshing && !(panGesture.state == .ended || panGesture.state == .cancelled) {
                scrollView.mj_header.state = MJRefreshState.refreshing
                _refresh()
                isRefreshing = true
            }
            headerView.y = 0
            headerView.height = HeaderView.defaultHeight
        } else {
            headerView.y = scrollView.contentOffset.y
            headerView.height = max(HeaderView.defaultHeight - scrollView.contentOffset.y, minY)
        }
        headerView.updateUI()
        setNeedsStatusBarAppearanceUpdate()
        
        /// 这里为什么要这么写？是因为你在真实处理含有网络数据的情况下，会存在计算headerView高度的情况，有可能你的headerView中还包含有置顶的动态数据，为了避免在多个网络处理过程中出现ui跳动的情况，这里需要这样处理一下
        otherView.y = HeaderView.defaultHeight
        segmentView.y = otherView.y + otherView.height
        pageScrollView.y = segmentView.y + segmentView.height
    }
    
    
    // 更新所以SegmentScrollView 的offset，在哦utterScrollView滑动到顶时需要使用
    func _updateSegmentScrollViewContentOffset(_ point: CGPoint) {
            segmentChildVCs.map { $0.tableView }
                .forEach { (tableView) in
                    tableView?.contentOffset = point
        }
    }
}

/// MARK: page滑动代理
extension NestedSlidingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x / UIScreen.width
        segmentView.highlight(index: Int(index))
        if curPageIndex != Int(index) {
            _resetCurrentSegmentVC(index: Int(index))
        }
    }
}

/// MARK: true 表示手势事件可以继续向subView传递
extension NestedSlidingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translationX = gesture.translation(in: view).x
            let translationY = gesture.translation(in: view).y
            if translationY == 0 {
                return true
            } else {
                /// 这里说一说手势处理，这个值可以设置得更大一些，保证在滑动垂直的时候触发了pageScrollView的滚动
                /// return fabsf(Float(translationX))/Float(translationY) >= 6.0
                /// 为了处理得更加严谨一点，应该这样（因为我们的headerView还可能存在更多的水平滑动，需要根具自己的需要判定在多大的偏移量的情况下处理horizontal滑动
                let point = gesture.location(in: view)
                let otherConvertPoint = view.convert(point, to: otherView)
                let pageConvertPoint = view.convert(point, to: pageScrollView)
                if otherView.point(inside: otherConvertPoint, with: nil) {  // 手势在otherView
                    return fabs(Float(translationX)) > fabs(Float(translationY))
                } else if pageScrollView.point(inside: pageConvertPoint, with: nil) {  // 手势在pageScrollView
                    return fabsf(Float(translationX))/Float(translationY) >= 6.0
                }
            }
        }
        return false
    }
    
    @objc func panGestureRecognizerAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let translationX = gesture.translation(in: view).x
            let translationY = gesture.translation(in: view).y
            let velocityX = gesture.velocity(in: view).x
            let velocityY = gesture.velocity(in: view).y
            /// 这里有个坑，本可以直接使用translation即可的，但是在iphoneX、plus上的translation.y 在屏幕的左侧会存在translationY 始终 == 0 的情况，也就是当用左手指滑动的时候，你会发现根本不会执行后面的逻辑了
            isVertical = fabsf(Float(translationY)) > fabsf(Float(translationX)) || fabsf(Float(velocityY)) > fabsf(Float(velocityX))
            animator.removeAllBehaviors()
            decelerationBehavior = nil
            springBehavior = nil
            break
        case .changed:
            if isVertical {
                print("------------  手势改变 --------")
                _decelerateScrollView(gesture.translation(in: view).y)
            }
            break
        case .cancelled:
            break
        case .ended:
            print("------------  手势结束 --------")
            if isVertical {
                /// MARK: 模拟减速滑动
                dynamicItem.center = view.bounds.origin
                let velocity = gesture.velocity(in: view)
                let inertialBehavior = UIDynamicItemBehavior(items: [dynamicItem])
                inertialBehavior.addLinearVelocity(CGPoint(x: 0, y: velocity.y), for: dynamicItem)
                inertialBehavior.resistance = 2.0
                var lastCenter = CGPoint.zero
                inertialBehavior.action = { [weak self] () in
                    guard let weakSelf = self else { return }
                    if weakSelf.isVertical {
                        let currentY = weakSelf.dynamicItem.center.y - lastCenter.y
                        weakSelf._decelerateScrollView(currentY)
                    }
                    lastCenter = weakSelf.dynamicItem.center
                }
                animator.addBehavior(inertialBehavior)
                decelerationBehavior = inertialBehavior
            }
            break
        default:
            break
        }
        /// 这里需要每次重新设置translation
        gesture.setTranslation(CGPoint.zero, in: view)
    }
    
    private func _decelerateScrollView(_ detal: CGFloat) {
        guard let curSegmentScrollView = curSegmentChildVC?.tableView else { return }
        
        let maxOffsetY: CGFloat = HeaderView.defaultHeight + otherView.height - UIScreen.naviBarHeight
        
        /// MARK: 仅有一个tab，并且tab不能够将mainScrollView推到顶部
        if curSegmentScrollView.contentSize.height + curSegmentScrollView.mj_footer.height < curSegmentScrollView.height && type == .singleTabNotFillScreen || type == .singleTabFillScreenNotFillContentSize {
            var mainOffsetY = outterScrollView.contentOffset.y - detal
            let offset1 = outterScrollView.contentOffset.y + outterScrollView.height
            let offset2 = pageScrollView.y + curSegmentScrollView.contentSize.height + curSegmentScrollView.mj_footer.height
            if mainOffsetY > 0 {
                if offset2 < outterScrollView.height {  // 可以往上多滑动40，有一个弹回效果
                    mainOffsetY = offset2 + 40 < offset1 ? 40 : mainOffsetY
                } else {
                    if mainOffsetY + outterScrollView.height > offset2 + 60 {
                        mainOffsetY = offset2 + 60 - outterScrollView.height
                    }
                }
            } else {
                if mainOffsetY < -200 {
                    mainOffsetY = -200
                }
            }
            outterScrollView.contentOffset = CGPoint(x: 0, y: mainOffsetY)
        } else {  /// MARK: 其他情况
            if outterScrollView.contentOffset.y >= maxOffsetY {
                var offsetY = curSegmentScrollView.contentOffset.y - detal
                if offsetY < 0 || curSegmentScrollView.contentSize.height < curSegmentScrollView.height {
                    offsetY = 0
                    var mainOffsetY = outterScrollView.contentOffset.y - detal
                    mainOffsetY = mainOffsetY < 0 ? outterScrollView.contentOffset.y - _rubberBandDistance(detal, UIScreen.height) : mainOffsetY
                    outterScrollView.contentOffset = CGPoint(x: 0, y: min(mainOffsetY, maxOffsetY))
                    print("-------- 处理其他情况 ---------- if ------------- ")
                } else if curSegmentScrollView.contentSize.height + curSegmentScrollView.mj_footer.height < curSegmentScrollView.height {
                    offsetY = 0
                    print("---------- 处理其他情况 -------- else if 1 ------------- ")
                } else if offsetY >= curSegmentScrollView.contentSize.height - curSegmentScrollView.height + curSegmentScrollView.mj_footer.height {
                    offsetY = curSegmentScrollView.contentOffset.y - _rubberBandDistance(detal, UIScreen.height)
                    print("--------- 处理其他情况 --------- else if 2 ------------- ")
                }
                curSegmentScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
            } else {  /// 处理mainScrollView
                var mainOffsetY = outterScrollView.contentOffset.y - detal
                if mainOffsetY >= maxOffsetY {
                    mainOffsetY = maxOffsetY
                } else if mainOffsetY < 0 {
                    mainOffsetY = outterScrollView.contentOffset.y - _rubberBandDistance(detal, UIScreen.height)
                    if mainOffsetY < -200 { // 下拉刷新最多下拉到200位置
                        mainOffsetY = -200
                    }
                }
                print("--------------- 处理outterScrollView  -------- \(mainOffsetY)")
                outterScrollView.contentOffset = CGPoint(x: 0, y: mainOffsetY)
                if mainOffsetY == 0 {
                    _updateSegmentScrollViewContentOffset(CGPoint.zero)
                }
            }
        }
        
        
        /// MARK: 模拟回弹效果
        let bounce0 = curSegmentScrollView.contentSize.height < curSegmentScrollView.height && (type == .singleTabNotFillScreen || type == .singleTabFillScreenNotFillContentSize) && pageScrollView.y + curSegmentScrollView.contentSize.height + curSegmentScrollView.mj_footer.height < outterScrollView.contentOffset.y + outterScrollView.height  // 单个到底的回弹
        let bounce1 = outterScrollView.contentOffset.y < 0   // main到顶的回弹
        let bounce2 = detal < 0 && curSegmentScrollView.contentSize.height > curSegmentScrollView.height && curSegmentScrollView.contentOffset.y > curSegmentScrollView.contentSize.height - curSegmentScrollView.height - curSegmentScrollView.mj_footer.height  // curSegment 到底的回弹
        let bounce = bounce0 || bounce1 || bounce2
        if bounce && decelerationBehavior != nil && springBehavior == nil {
            var target = CGPoint.zero
            if bounce0 {
                dynamicItem.center = outterScrollView.contentOffset
                let offset = pageScrollView.y + curSegmentScrollView.contentSize.height + curSegmentScrollView.mj_footer.height
                if offset < outterScrollView.height {
                    target = CGPoint.zero
                } else {
                    target = CGPoint(x: 0, y: offset - outterScrollView.height + 10)
                }
                _springScrollViewContentOffset(outterScrollView, target)
            } else if outterScrollView.contentOffset.y < 0 {
                dynamicItem.center = outterScrollView.contentOffset
                if outterScrollView.contentOffset.y < -outterScrollView.mj_header.height - UIScreen.statusBarMoreHeight - 20 {
                    target = CGPoint(x: 0, y: -outterScrollView.mj_header.height - UIScreen.statusBarMoreHeight)
                } else {
                    target = CGPoint.zero
                }
                _springScrollViewContentOffset(outterScrollView, target)
                print(" spring ------------------   if  ------------- \(NSStringFromCGPoint(target))")
            } else if curSegmentScrollView.contentOffset.y > curSegmentScrollView.contentSize.height - curSegmentScrollView.height + curSegmentScrollView.mj_footer.height {
                dynamicItem.center = curSegmentScrollView.contentOffset
                /// MARK: 需要将footer 显示出来
                let offsetY = curSegmentScrollView.contentSize.height - curSegmentScrollView.height + curSegmentScrollView.mj_footer.height
                target = CGPoint(x: 0, y: offsetY < 0 ? 0 : offsetY)
                _springScrollViewContentOffset(curSegmentScrollView, target)
                print(" spring ------------------   else  ------------- \(NSStringFromCGPoint(target))")
            }
        }
    }
    
    /// 处理回弹
    private func _springScrollViewContentOffset(_ scrollView: UIScrollView, _ point: CGPoint) {
        dynamicItem.center = scrollView.contentOffset
        animator.removeAllBehaviors()
        decelerationBehavior = nil
        springBehavior = nil
        let tmpSprintBehavior = UIAttachmentBehavior(item: dynamicItem, attachedToAnchor: point)
        tmpSprintBehavior.length = 0
        tmpSprintBehavior.damping = 1
        tmpSprintBehavior.frequency = 2
        tmpSprintBehavior.action = { [weak self] () in
            guard let weakSelf = self else { return }
            scrollView.contentOffset = weakSelf.dynamicItem.center
            if scrollView == weakSelf.outterScrollView && scrollView.contentOffset.y == 0 {
                weakSelf._updateSegmentScrollViewContentOffset(CGPoint.zero)
            }
        }
        animator.addBehavior(tmpSprintBehavior)
        springBehavior = tmpSprintBehavior
    }
    
    private func _rubberBandDistance(_ offset: CGFloat, _ dimission: CGFloat) -> CGFloat {
        let constant: CGFloat = 0.55
        let result = (constant * CGFloat(fabsf(Float(offset))) * dimission) / (dimission + constant * CGFloat(fabs(Float(offset))))
        return offset < 0.0 ? -result : result
    }
}

extension NestedSlidingViewController {
    class RubberDynamicItem: NSObject, UIDynamicItem {
        var center: CGPoint = CGPoint.zero
        var bounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        var transform: CGAffineTransform = CGAffineTransform.identity
    }
}
