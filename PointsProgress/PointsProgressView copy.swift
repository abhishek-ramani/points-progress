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

    private func setupView() {
    
        self.backgroundColor = .clear
        
        pin = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        pin.image = UIImage(named: "ic_pin")
        self.addSubview(pin)
        pin.center.x = 0
        
        stackView = UIStackView(frame: CGRect(x: 0, y: pin.frame.origin.y+pin.frame.size.height, width: self.bounds.width, height: 20))
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        stackView.spacing = -2
        self.addSubview(stackView)
        
        stackViewLbls = UIStackView(frame: CGRect(x: 0, y: stackView.frame.origin.y+stackView.frame.size.height, width: self.bounds.width, height: 20))
        stackViewLbls.axis = .horizontal
        stackViewLbls.alignment = .top
        stackViewLbls.distribution = .fill
        stackViewLbls.backgroundColor = .clear
        stackViewLbls.spacing = -2
        self.addSubview(stackViewLbls)
    }
    
    private func addProgressBars() {
                
        let pointCircleWidth: CGFloat = 15.0
        let totalWidthForProgressBars = self.frame.size.width - (CGFloat(_midPoints.count-1) * pointCircleWidth)
        let widthForFirstLastProgressBar = (totalWidthForProgressBars / CGFloat(_midPoints.count - 1))/2
        let widthForMiddleProgressBar = totalWidthForProgressBars / CGFloat(_midPoints.count - 1)
        
        let pointLblWidth: CGFloat = 50.0
        let totalWidthForSpace = self.frame.size.width - (CGFloat(_midPoints.count-1) * pointLblWidth)
        let widthForFirstLastSpace = (totalWidthForSpace / CGFloat(_midPoints.count - 1))/2
        let widthForMiddleSpace = totalWidthForSpace / CGFloat(_midPoints.count - 1)
        
        for n in 0..<_midPoints.count {
            
            //PROGRESS VIEW
            
            let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: (n != 0 && n != _midPoints.count-1) ? widthForMiddleProgressBar : widthForFirstLastProgressBar, height: 5))
            progressView.progressTintColor = .brown
            progressView.trackTintColor = .groupTableViewBackground
            progressView.progress = 0
            stackView.addArrangedSubview(progressView)
            arrProgressView.append(progressView)
            
            progressView.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint_PV = NSLayoutConstraint(item: progressView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: progressView.frame.size.width)
            let heightConstraint_PV = NSLayoutConstraint(item: progressView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: progressView.frame.size.height)
            progressView.addConstraints([widthConstraint_PV, heightConstraint_PV])

            //POINTS BUTTON

            let btnPoints = UIButton(frame: CGRect(x: 0, y: 0, width: (n != _midPoints.count-1) ? pointCircleWidth : 0, height: pointCircleWidth))
            btnPoints.clipsToBounds = true
            btnPoints.backgroundColor = .groupTableViewBackground
            btnPoints.layer.cornerRadius = pointCircleWidth/2
            stackView.addArrangedSubview(btnPoints)
            arrPointButton.append(btnPoints)

            btnPoints.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: btnPoints, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (n != _midPoints.count-1) ? btnPoints.frame.size.width : 0)
            let heightConstraint = NSLayoutConstraint(item: btnPoints, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: btnPoints.frame.size.height)
            btnPoints.addConstraints([widthConstraint, heightConstraint])
            
            //print("\(n) -> \(_midPoints[n])")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            for subVw in self.stackView.arrangedSubviews {
                
                if(subVw.isKind(of: UIProgressView.self)) {
                    self.arrFrameProgressView.append(subVw.frame)
                }

                if(subVw.isKind(of: UIButton.self)) {
                    self.arrFramePointButton.append(subVw.frame)
                }
            }
        }
        
        for btn in arrPointButton {
            stackView.bringSubviewToFront(btn)
        }
        
        for n in 0..<_midPoints.count {
            
            //White Space
            let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: (n != 0 && n != _midPoints.count-1) ? widthForMiddleSpace : widthForFirstLastSpace, height: 5))
            spaceView.backgroundColor = .clear
            stackViewLbls.addArrangedSubview(spaceView)
            
            spaceView.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint_SV = NSLayoutConstraint(item: spaceView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: spaceView.frame.size.width)
            let heightConstraint_SV = NSLayoutConstraint(item: spaceView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: spaceView.frame.size.height)
            spaceView.addConstraints([widthConstraint_SV, heightConstraint_SV])

            //Lables
            let lblPoint = UILabel(frame: CGRect(x: 0, y: 0, width: (n != _midPoints.count-1) ? pointLblWidth : 0, height: 25))
            lblPoint.clipsToBounds = true
            lblPoint.textAlignment = .center
            lblPoint.textColor = .lightGray
            lblPoint.font = .boldSystemFont(ofSize: 15)
            lblPoint.text = "\(_midPoints[n])"
            lblPoint.adjustsFontSizeToFitWidth = true
            lblPoint.minimumScaleFactor = 0.5
            stackViewLbls.addArrangedSubview(lblPoint)
            arrPointLabel.append(lblPoint)
            
            lblPoint.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: lblPoint, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: lblPoint.frame.size.width)
            let heightConstraint = NSLayoutConstraint(item: lblPoint, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: lblPoint.frame.size.height)
            lblPoint.addConstraints([widthConstraint, heightConstraint])
        }
        
    }
    
    func setProgressFor(points: Int) {
        
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
                    
                    let totalPointsForProgress = _midPoints[n]
                    let pointsForProgress = points 
                    
                    let delay = delayForIncreasePoints(totalPoints: totalPointsForProgress, progressPoint: pointsForProgress)
                    
                    let tempDelay = (indexFrom == n) ? 0 : afterDelay
                    afterDelay += delay
                                        
                    let progress = Float(pointsForProgress)/Float(totalPointsForProgress)
                    
                    pinX = frameProgressView.origin.x + (CGFloat(progress) * frameProgressView.size.width)
                    if(totalPointsForProgress == pointsForProgress){
                        pinX = frameBtnPoints.origin.x  + (frameBtnPoints.size.width/2)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress( progress, animated: true )
                        }
                        
                        if(totalPointsForProgress == pointsForProgress){
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                btnPoints.backgroundColor = .brown
                                lblPoints.textColor = .brown
                            }
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress( progress, animated: true )
                        }

                        if(totalPointsForProgress == pointsForProgress){
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                btnPoints.backgroundColor = .brown
                                lblPoints.textColor = .brown
                            }
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress( progress, animated: true )
                        }
                        
                        if(totalPointsForProgress == pointsForProgress){
                                                        
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                btnPoints.backgroundColor = .brown
                                lblPoints.textColor = .brown
                            }
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        if(totalPointsForProgress != pointsForProgress){
                            btnPoints.backgroundColor = .groupTableViewBackground
                            lblPoints.textColor = .lightGray
                        }
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress(progress, animated: true)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            if(isManuallyChangedProgress){
                                progressView.setProgress(0, animated: true)
                            }
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + tempDelay) {
                        
                        if(totalPointsForProgress != pointsForProgress){
                            btnPoints.backgroundColor = .groupTableViewBackground
                            lblPoints.textColor = .lightGray
                        }
                        
                        UIView.animate(withDuration: delay) {
                            progressView.setProgress(progress, animated: true)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            if(isManuallyChangedProgress){
                                progressView.setProgress(0, animated: true)
                            }
                        }
                    }
                }
            }
            self.setPointPinTo(centerX: pinX, withAnimationTime: afterDelay)
        }
        _lastPoints = points
    }
    
    private func delayForIncreasePoints(totalPoints: Int, progressPoint: Int) -> Double {
        
        let delay = (Double(progressPoint) * 0.4)/Double(totalPoints)
        return delay
    }

    private func delayForDecreasePoints(totalPoints: Int, currentPoints: Int, progressPoint: Int) -> Double {
        
        let delayIncrease1 = (Double(currentPoints) * 0.4)/Double(totalPoints)
        let delayIncrease2 = (Double(progressPoint) * 0.4)/Double(totalPoints)

        var delay = delayIncrease1 - delayIncrease2

        if(delay <= 0) {
            delay = 0
        }

        return delay
    }
    
    private func setPointPinTo(centerX: CGFloat, withAnimationTime: Double) {
        
        UIView.animate(withDuration: withAnimationTime) {
            self.pin.center.x = centerX
        }
    }
}
