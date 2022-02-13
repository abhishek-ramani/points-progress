//
//  ViewController.swift
//  PointsProgress
//
//  Created by AppBits5 on 19/06/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var customProgressView :UIView!
    @IBOutlet weak var lblPoints :UILabel!

    var points: Int = 0
    var vwProgress: PointsProgressView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vwProgress = PointsProgressView(frame: customProgressView.bounds, minPoint: 0, maxPoint: 150, midPoints: [10, 20, 40, 70, 100])
        vwProgress?.progressTintColor = .brown
        vwProgress?.trackTintColor = .groupTableViewBackground
        vwProgress?.pointLabelActiveColor = .brown
        vwProgress?.pointLabelNormalColor = .lightGray
        vwProgress?.midPointBackgroundColor = .white

        self.customProgressView.addSubview(vwProgress!)
        vwProgress?.bindFrameToSuperviewBounds()

        self.lblPoints.text = "\(self.points)"
        self.vwProgress?.setProgressFor(points: self.points)
    }
    
    @IBAction func onPlusButtonClick(_ sender: UIButton) {
        points += getRandomValue()
        points = (points > 150) ? 150 : points

        lblPoints.text = "\(points)"
        vwProgress?.setProgressFor(points: points)
    }
    
    @IBAction func onMinusButtonClick(_ sender: UIButton) {
        points -= getRandomValue()
        points = (points < 0) ? 0 : points
        
        lblPoints.text = "\(points)"
        vwProgress?.setProgressFor(points: points)
    }
    
    func getRandomValue() -> Int {
        let number = Int.random(in: 1...50)
        return number
    }
}

extension UIView {

    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
}
