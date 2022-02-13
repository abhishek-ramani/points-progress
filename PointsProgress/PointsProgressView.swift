//
//  PointsProgressView.swift
//  PointsProgress
//
//  Created by AppBits5 on 19/06/21.
//

import UIKit

// Screen width.
var screenWidth: CGFloat =  UIScreen.main.bounds.width
// Screen height.
var screenHeight: CGFloat = UIScreen.main.bounds.height

class PointsProgressView: UIView {

    public var progressTintColor: UIColor = .brown {
        didSet {
            for progressView in arrProgressView {
                progressView.progressTintColor = progressTintColor
            }
        }
    }
    
    public var trackTintColor: UIColor = .groupTableViewBackground {
        didSet {
            for progressView in arrProgressView {
                progressView.trackTintColor = trackTintColor
            }
            
            for btnPoint in arrPointButton {
                btnPoint.tintColor = trackTintColor
            }
        }
    }

    public var pointLabelActiveColor: UIColor = .brown {
        didSet {
            
        }
    }

    public var pointLabelNormalColor: UIColor = .lightGray {
        didSet {
            for lblPoint in arrPointLabel {
                lblPoint.textColor = pointLabelNormalColor
            }
        }
    }
    
    public var midPointBackgroundColor: UIColor = .white {
        didSet {
            for btnPoint in arrPointButton {
                btnPoint.backgroundColor = midPointBackgroundColor
            }
        }
    }
    
    private static let image_PointPin: UIImage = UIImage(named: "ic_pin")!
    private static let image_PointCircle: UIImage = UIImage(named: "ic_points_slider_ring")!
    private static let image_PointCircleActive: UIImage = UIImage(named: "ic_start_circle_yellow")!

    private let stackSpacing: CGFloat = -2
    private static let pointPinHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 12.0 : 10.0
    private static let pointCircleHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 20.0 : 15.0
    private static let pointProgressHeight: CGFloat = 3.0
    private static let pointLabelHeight: CGFloat = 25
    private static let pointLblWidth: CGFloat = 50.0
    static let heightPointsProgressView: CGFloat = pointPinHeight + pointCircleHeight + pointLabelHeight

    let group = DispatchGroup()
    var lock: Bool = false
    var arrWaitForPoints: [Int] = []
    
    private var arrProgressView: [UIProgressView] = []
    private var arrPointButton: [UIButton] = []
    private var arrPointLabel: [UILabel] = []

    private var arrFrameProgressView: [CGRect] = []
    private var arrFramePointButton: [CGRect] = []
    
    private var _minPoint: Int = 0
    private var _maxPoint: Int = 0
    private var _midPoints: [Int] = []
        
    private var _lastPoints: Int = 0
    
    private var pin: UIImageView!
    private var stackView: UIStackView!
    private var stackViewLbls: UIStackView!

    convenience init(frame: CGRect, minPoint: Int, maxPoint: Int, midPoints: [Int]) {
        
        self.init(frame: frame)
        _minPoint = minPoint
        _maxPoint = maxPoint
        _midPoints = midPoints
        
        if(!_midPoints.contains(_maxPoint)){
            _midPoints.append(_maxPoint)
        }
        
        setupView()
        addProgressBars()
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        //setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func orientationChanged(_ notification: NSNotification) {

        self.updateFrameArray()
        self.setProgressFor(points:  _lastPoints)
    }

    fileprivate func setupView() {
    
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        );

        self.backgroundColor = .clear
        
        pin = UIImageView(frame: CGRect(x: 0, y: 0, width: PointsProgressView.pointPinHeight, height: PointsProgressView.pointPinHeight))
        pin.image = PointsProgressView.image_PointPin.withRenderingMode(.alwaysTemplate)
        pin.tintColor = UIColor(red: 47/255, green: 155/255, blue: 79/255, alpha: 1.0)
        self.addSubview(pin)
        pin.center.x = 0
        
        stackView = UIStackView(frame: CGRect(x: 0, y: pin.frame.origin.y+pin.frame.size.height, width: self.bounds.width, height: PointsProgressView.pointCircleHeight))
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        stackView.spacing = stackSpacing
        self.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: stackView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: PointsProgressView.pointCircleHeight).isActive = true
        NSLayoutConstraint(item: stackView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stackView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stackView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: pin.frame.origin.y+pin.frame.size.height).isActive = true
        
        stackViewLbls = UIStackView(frame: CGRect(x: 0, y: stackView.frame.origin.y+stackView.frame.size.height, width: self.bounds.width, height: PointsProgressView.pointLabelHeight))
        stackViewLbls.axis = .horizontal
        stackViewLbls.alignment = .top
        stackViewLbls.distribution = .fill
        stackViewLbls.backgroundColor = .clear
        stackViewLbls.spacing = stackSpacing
        self.addSubview(stackViewLbls)
        
        stackViewLbls.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: stackViewLbls!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stackViewLbls!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stackViewLbls!, attribute: .top, relatedBy: .equal, toItem: stackView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: stackViewLbls!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: PointsProgressView.pointLabelHeight).isActive = true
    }
    
    fileprivate func addProgressBars() {
                
        let totalWidthForProgressBars = (self.frame.size.width - (CGFloat(_midPoints.count-1) * PointsProgressView.pointCircleHeight)) + ((CGFloat(_midPoints.count-1) * (stackSpacing*(-1)) * 2) + stackSpacing)
        let widthForFirstLastProgressBar = (totalWidthForProgressBars / CGFloat(_midPoints.count - 1))/2
        let widthForMiddleProgressBar = totalWidthForProgressBars / CGFloat(_midPoints.count - 1)
                
        let totalWidthForSpace = (self.frame.size.width - (CGFloat(_midPoints.count-1) * PointsProgressView.pointLblWidth)) + ((CGFloat(_midPoints.count-1) * (stackSpacing*(-1)) * 2) + stackSpacing)
        let widthForFirstLastSpace = (totalWidthForSpace / CGFloat(_midPoints.count - 1))/2
        let widthForMiddleSpace = totalWidthForSpace / CGFloat(_midPoints.count - 1)
        
        for n in 0..<_midPoints.count {
            
            //PROGRESS VIEW
            
            let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: (n != 0 && n != _midPoints.count-1) ? widthForMiddleProgressBar : widthForFirstLastProgressBar, height: PointsProgressView.pointProgressHeight))
            progressView.progressTintColor = progressTintColor
            progressView.trackTintColor = trackTintColor
            progressView.progress = 0
            stackView.addArrangedSubview(progressView)
            arrProgressView.append(progressView)
            
            progressView.translatesAutoresizingMaskIntoConstraints = false
            //let widthConstraint_PV = NSLayoutConstraint(item: progressView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: progressView.frame.size.width)
            let heightConstraint_PV = NSLayoutConstraint(item: progressView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: PointsProgressView.pointProgressHeight)
            progressView.addConstraints([heightConstraint_PV])
            
            //POINTS BUTTON

            let btnPoints = UIButton(frame: CGRect(x: 0, y: 0, width: (n != _midPoints.count-1) ? PointsProgressView.pointCircleHeight : 0, height: PointsProgressView.pointCircleHeight))
            btnPoints.clipsToBounds = true
            btnPoints.layer.cornerRadius = PointsProgressView.pointCircleHeight/2
            btnPoints.backgroundColor = midPointBackgroundColor
            btnPoints.tintColor = trackTintColor
            btnPoints.setImage(PointsProgressView.image_PointCircle.withRenderingMode(.alwaysTemplate) , for: .normal)
            btnPoints.setImage(PointsProgressView.image_PointCircleActive, for: .selected)
            stackView.addArrangedSubview(btnPoints)
            arrPointButton.append(btnPoints)

            btnPoints.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: btnPoints, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (n != _midPoints.count-1) ? btnPoints.frame.size.width : 0)
            let heightConstraint = NSLayoutConstraint(item: btnPoints, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: btnPoints.frame.size.height)
            btnPoints.addConstraints([widthConstraint, heightConstraint])
            
            //print("\(n) -> \(_midPoints[n])")
        }
        
        for (index, progressVw) in arrProgressView.enumerated() {
            let progressVw1 = progressVw;
            if(index == arrProgressView.count-1) {

                let progressVw2 = arrProgressView[0];
                NSLayoutConstraint(item: progressVw1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: progressVw2, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0).isActive = true
            }
            else {
                let progressVw2 = arrProgressView[index+1];
                NSLayoutConstraint(item: progressVw1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: progressVw2, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0).isActive = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateFrameArray()
        }
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            for subVw in self.stackView.arrangedSubviews {
                
                if(subVw.isKind(of: UIProgressView.self)) {
                    self.arrFrameProgressView.append(subVw.frame)
                }

                if(subVw.isKind(of: UIButton.self)) {
                    self.arrFramePointButton.append(subVw.frame)
                }
            }
            
            if(self.arrWaitForPoints.count > 0){
                self.setProgressFor(points: self.arrWaitForPoints[0])
                self.arrWaitForPoints.remove(at: 0)
            }
        }
        */
        for btn in arrPointButton {
            stackView.bringSubviewToFront(btn)
        }
        
        var arrSpaceView: [UIView] = []
        for n in 0..<_midPoints.count {
            
            //White Space
            let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: (n != 0 && n != _midPoints.count-1) ? widthForMiddleSpace : widthForFirstLastSpace, height: 5))
            spaceView.backgroundColor = .clear
            stackViewLbls.addArrangedSubview(spaceView)
            arrSpaceView.append(spaceView)
            
            spaceView.translatesAutoresizingMaskIntoConstraints = false
            //let widthConstraint_SV = NSLayoutConstraint(item: spaceView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (n != 0 && n != _midPoints.count-1) ? widthForMiddleSpace : widthForFirstLastSpace)
            let heightConstraint_SV = NSLayoutConstraint(item: spaceView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 5)
            spaceView.addConstraints([heightConstraint_SV])

            //Labels
            let lblPoint = UILabel(frame: CGRect(x: 0, y: 0, width: (n != _midPoints.count-1) ? PointsProgressView.pointLblWidth : 0, height: PointsProgressView.pointLabelHeight))
            lblPoint.clipsToBounds = true
            lblPoint.textAlignment = .center
            lblPoint.textColor = pointLabelNormalColor
            lblPoint.font = .boldSystemFont(ofSize: 15)
            lblPoint.text = "\(_midPoints[n])"
            lblPoint.adjustsFontSizeToFitWidth = true
            lblPoint.minimumScaleFactor = 0.5
            stackViewLbls.addArrangedSubview(lblPoint)
            arrPointLabel.append(lblPoint)
            
            lblPoint.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: lblPoint, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (n != _midPoints.count-1) ? PointsProgressView.pointLblWidth : 0)
            let heightConstraint = NSLayoutConstraint(item: lblPoint, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: PointsProgressView.pointLabelHeight)
            lblPoint.addConstraints([widthConstraint, heightConstraint])
        }
        
        for (index, spaceView) in arrSpaceView.enumerated() {
            let spaceView1 = spaceView;
            if(index == arrSpaceView.count-1) {

                let spaceView2 = arrSpaceView[0];
                NSLayoutConstraint(item: spaceView1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: spaceView2, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0).isActive = true
            }
            else {
                let spaceView2 = arrSpaceView[index+1];
                NSLayoutConstraint(item: spaceView1, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: spaceView2, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0).isActive = true
            }
        }
    }
    
    func setProgressFor(points: Int) {
        
        if(lock || self.arrFrameProgressView.count <= 0){
            arrWaitForPoints.removeAll()
            arrWaitForPoints.append(points)
            return
        }
        lock = true
        
        var points = points
        
        if(points < _minPoint){
            points = _minPoint
        }
        
        if(points > _maxPoint){
            points = _maxPoint
        }
        
        if(_lastPoints < points){
            //increase points
            
            var indexFrom = 0
            var indexTo = 0
            for n in 0..<_midPoints.count {
                
                if(n != 0 && (_lastPoints > _midPoints[n-1] && _lastPoints <= _midPoints[n])){
                    indexFrom = n
                }
                
                if(n != 0 && (points > _midPoints[n-1] && points <= _midPoints[n])){
                    indexTo = n
                }
            }
            
            var afterDelay: Double = 0
            var pinX: CGFloat = 0

            for n in indexFrom..<indexTo+1 {
                
                let progressView: UIProgressView = arrProgressView[n]
                let btnPoints: UIButton = arrPointButton[n]
                let lblPoints: UILabel = arrPointLabel[n]

                let frameProgressView: CGRect = arrFrameProgressView[n]
                let frameBtnPoints: CGRect = arrFramePointButton[n]
                
                if(n == 0 && points <= _midPoints[n]){
                    
                    let totalPointsForProgress = _midPoints[n] - _minPoint
                    let pointsForProgress = points - _minPoint
                    
                    let delay = delayForIncreasePoints(totalPoints: totalPointsForProgress, progressPoint: pointsForProgress)
                    
                    let tempDelay = (indexFrom == n) ? 0 : afterDelay
                    afterDelay += delay
                                        
                    let progress = Float(pointsForProgress)/Float(totalPointsForProgress)
                    
                    pinX = frameProgressView.origin.x + (CGFloat(progress) * frameProgressView.size.width)
                    if(totalPointsForProgress == pointsForProgress){
                        pinX = frameBtnPoints.origin.x  + (frameBtnPoints.size.width/2)
                    }
                    
                    group.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress( progress, animated: true )
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            if(totalPointsForProgress == pointsForProgress){
                                btnPoints.isSelected = true
                                lblPoints.textColor = self.pointLabelActiveColor
                            }
                            self.group.leave()
                        }
                    }
                }
                else if(_midPoints[n] <= points){
                    
                    let totalPointsForProgress = _midPoints[n]
                    let pointsForProgress = _midPoints[n]
                    
                    let delay = delayForIncreasePoints(totalPoints: totalPointsForProgress, progressPoint: pointsForProgress)
                    let tempDelay = (indexFrom == n) ? 0 : afterDelay
                    afterDelay += delay
                            
                    let progress: Float = 1.0
                    
                    pinX = frameProgressView.origin.x + frameProgressView.size.width
                    if(totalPointsForProgress == pointsForProgress){
                        pinX = frameBtnPoints.origin.x + ((points > self._midPoints[n]) ? frameBtnPoints.size.width : frameBtnPoints.size.width/2)
                    }
                    
                    group.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress( progress, animated: true )
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            if(totalPointsForProgress == pointsForProgress){
                                
                                btnPoints.isSelected = true
                                lblPoints.textColor = self.pointLabelActiveColor
                            }
                            self.group.leave()
                        }
                    }
                }
                else if(n != 0 && (points > _midPoints[n-1] && points <= _midPoints[n])) {
                    
                    let totalPointsForProgress = _midPoints[n] - _midPoints[n-1]
                    let pointsForProgress = points - _midPoints[n-1]
                    
                    let delay = delayForIncreasePoints(totalPoints: totalPointsForProgress, progressPoint: pointsForProgress)
                    let tempDelay = (indexFrom == n) ? 0 : afterDelay
                    afterDelay += delay
                        
                    let progress = Float(pointsForProgress)/Float(totalPointsForProgress)

                    pinX = frameProgressView.origin.x + (CGFloat(progress) * frameProgressView.size.width)
                    if(totalPointsForProgress == pointsForProgress){
                        pinX = frameBtnPoints.origin.x + (frameBtnPoints.size.width/2)
                    }
                    
                    group.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress( progress, animated: true )
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            if(totalPointsForProgress == pointsForProgress){
                                btnPoints.isSelected = true
                                lblPoints.textColor = self.pointLabelActiveColor
                            }
                            self.group.leave()
                        }
                    }
                }
            }
            
            self.setPointPinTo(centerX: pinX, withAnimationTime: afterDelay)
        }
        else {
            //decrease points
            
            var temp_mid_Points = _midPoints
            if(!temp_mid_Points.contains(_minPoint)){
                temp_mid_Points.insert(_minPoint, at: 0)
            }

            var indexFrom = 0
            var indexTo = 0
            for n in stride(from: temp_mid_Points.count-1, to: 0, by: -1) {

                if(n != 0 && _lastPoints <= temp_mid_Points[n]){
                    indexFrom = n
                }
                
                if(n != 0 && points <= temp_mid_Points[n]){
                    indexTo = n
                }
            }

            var afterDelay: Double = 0
            var pinX: CGFloat = 0

            var pointsAfterDeduct = _lastPoints
            
            for n in stride(from: indexFrom, to: indexTo-1, by: -1) {
                
                let progressView: UIProgressView = arrProgressView[n-1]
                let btnPoints: UIButton = arrPointButton[n-1]
                let lblPoints: UILabel = arrPointLabel[n-1]

                let frameProgressView: CGRect = arrFrameProgressView[n-1]
                let frameBtnPoints: CGRect = arrFramePointButton[n-1]
                
                if(n != 0 && points <= temp_mid_Points[n]){
                                        
                    let totalPointsForProgress = temp_mid_Points[n] - temp_mid_Points[n-1]
                    let currentPoints = pointsAfterDeduct - temp_mid_Points[n-1]
                    let deductPoints = (points <= temp_mid_Points[n-1]) ? pointsAfterDeduct-temp_mid_Points[n-1] : pointsAfterDeduct-points
                    let pointsForProgress = currentPoints - deductPoints
                    pointsAfterDeduct = temp_mid_Points[n-1] + pointsForProgress
                    
                    var isManuallyChangedProgress:Bool = false
                    var progress = Float(pointsForProgress)/Float(totalPointsForProgress)
                    if(progress <= 0){
                        progress = 0.01
                        isManuallyChangedProgress = true
                    }
                    //print("n: \(n) --> currentPoints: \(currentPoints) --> deductPoints: \(deductPoints) --> ForProgress: \(pointsForProgress) --> pointsAfterDeduct: \(pointsAfterDeduct)")
                    
                    pinX = frameProgressView.origin.x + (CGFloat(progress) * frameProgressView.size.width)
                    if(totalPointsForProgress == pointsForProgress){
                        pinX = frameBtnPoints.origin.x + (frameBtnPoints.size.width/2)
                    }
                    
                    let delay = delayForDecreasePoints(totalPoints: totalPointsForProgress, currentPoints: currentPoints, progressPoint: pointsForProgress)
                    let tempDelay = (indexFrom == n) ? 0 : afterDelay
                    afterDelay += delay
                    
                    group.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        if(totalPointsForProgress != pointsForProgress){
                            btnPoints.isSelected = false
                            lblPoints.textColor = self.pointLabelNormalColor
                        }
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress(progress, animated: true)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            if(isManuallyChangedProgress){
                                progressView.setProgress(0, animated: true)
                            }
                            self.group.leave()
                        }
                    }
                }
                else if(n == 0 && points < temp_mid_Points[n]) {
                                        
                    let totalPointsForProgress = temp_mid_Points[n]
                    let currentPoints = pointsAfterDeduct
                    let deductPoints = pointsAfterDeduct-points
                    let pointsForProgress = currentPoints - deductPoints
                    pointsAfterDeduct = pointsForProgress
                    
                    var isManuallyChangedProgress:Bool = false
                    var progress = Float(pointsForProgress)/Float(totalPointsForProgress)
                    if(progress <= 0){
                        progress = 0.01
                        isManuallyChangedProgress = true
                    }
                    //print("n: \(n) --> currentPoints: \(currentPoints) --> deductPoints: \(deductPoints) --> ForProgress: \(pointsForProgress) --> pointsAfterDeduct: \(pointsAfterDeduct)")
                    
                    pinX = frameProgressView.origin.x + (CGFloat(progress) * frameProgressView.size.width)
                    if(totalPointsForProgress == pointsForProgress){
                        pinX = frameBtnPoints.origin.x + (frameBtnPoints.size.width/2)
                    }
                    
                    let delay = delayForDecreasePoints(totalPoints: totalPointsForProgress, currentPoints: currentPoints, progressPoint: pointsForProgress)
                    let tempDelay = (indexFrom == n) ? 0 : afterDelay
                    afterDelay += delay
                    
                    group.enter()
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        if(totalPointsForProgress != pointsForProgress){
                            btnPoints.isSelected = false
                            lblPoints.textColor = self.pointLabelNormalColor
                        }
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress(progress, animated: true)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            if(isManuallyChangedProgress){
                                progressView.setProgress(0, animated: true)
                            }
                            self.group.leave()
                        }
                    }
                }
            }
            self.setPointPinTo(centerX: pinX, withAnimationTime: afterDelay)
        }
        
        _lastPoints = points
        
        group.notify(queue: .global(qos: .default), execute: {
            
            DispatchQueue.main.async {
                
                self.lock = false
                if(self.arrWaitForPoints.count > 0){
                    self.setProgressFor(points: self.arrWaitForPoints[0])
                    self.arrWaitForPoints.remove(at: 0)
                }
            }
        })
    }
    
    fileprivate func delayForIncreasePoints(totalPoints: Int, progressPoint: Int) -> Double {
        
        let delay = (Double(progressPoint) * 0.4)/Double(totalPoints)
        return delay
    }

    fileprivate func delayForDecreasePoints(totalPoints: Int, currentPoints: Int, progressPoint: Int) -> Double {
        
        let delayIncrease1 = (Double(currentPoints) * 0.4)/Double(totalPoints)
        let delayIncrease2 = (Double(progressPoint) * 0.4)/Double(totalPoints)

        var delay = delayIncrease1 - delayIncrease2

        if(delay <= 0) {
            delay = 0
        }

        return delay
    }
    
    fileprivate func setPointPinTo(centerX: CGFloat, withAnimationTime: Double) {
                
        UIView.animate(withDuration: withAnimationTime) {
            self.pin.center.x = centerX
        }
    }

    fileprivate func updateFrameArray() {
        
        self.arrFrameProgressView.removeAll()
        self.arrFramePointButton.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            for subVw in self.stackView.arrangedSubviews {
                
                if(subVw.isKind(of: UIProgressView.self)) {
                    self.arrFrameProgressView.append(subVw.frame)
                }

                if(subVw.isKind(of: UIButton.self)) {
                    self.arrFramePointButton.append(subVw.frame)
                }
            }
            
            if(self.arrWaitForPoints.count > 0){
                self.setProgressFor(points: self.arrWaitForPoints[0])
                self.arrWaitForPoints.remove(at: 0)
            }
        }
    }
}
