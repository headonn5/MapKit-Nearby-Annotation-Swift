//
//  SpinnerView.swift
//  AsiaProject
//
//  Created by Nishant Paul on 31/10/19.
//  Copyright © 2019 Nishant Paul. All rights reserved.
//

import UIKit

class SpinnerView: UIView {
    
    private var label: UILabel
    private var spinner: UIActivityIndicatorView
    var labelColor: UIColor? {
        didSet {
            label.textColor = labelColor!
        }
    }

    override init(frame: CGRect) {
        // Create a Label
        self.label = UILabel(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height/2))
        // Create a Spinner
        self.spinner = UIActivityIndicatorView(style: .gray)
        // Call to the super initializer from the designated initializer
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addChildView(toView view: UIView, atYOffset yOffset: CGFloat, andXOffset xOffset: CGFloat, withText text: String) {
        
        // Label properties
        label.text = text
        self.addSubview(label)
        
        // Spinner properties
        spinner.startAnimating()
        self.addSubview(spinner)
        
        // Spinner constraints
        spinner.translatesAutoresizingMaskIntoConstraints = false
        let sCenterXConstraint = spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let sCenterYConstraint = spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        self.addConstraints([sCenterXConstraint, sCenterYConstraint])
        
        // Label constraints
        label.translatesAutoresizingMaskIntoConstraints = false
//        let leadingConstraint = label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0)
        let lCenterXConstraint = label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let lCenterYConstraint = label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -(spinner.frame.height + 10.0))
        self.addConstraints([lCenterXConstraint, lCenterYConstraint])
        
        // Add self to the parent view
        view.addSubview(self)
        
        // Self view constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = getCenteredConstraints(forView: view, yOffset: yOffset, xOffset: xOffset)
        
        view.addConstraints(constraints)
    }
    
    private func getCenteredConstraints(forView view: UIView, yOffset: CGFloat, xOffset: CGFloat) -> [NSLayoutConstraint] {
        let widthConstant = view.frame.size.width
        let heightConstant = view.frame.size.height
        
        let horizontalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: xOffset)
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: yOffset)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: widthConstant/2)
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: heightConstant/6)
        
        return [horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint]
    }
    
    deinit {
        print("Deinit called")
    }
}
