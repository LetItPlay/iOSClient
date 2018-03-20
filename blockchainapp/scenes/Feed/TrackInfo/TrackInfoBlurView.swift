//
//  TrackInfoBlurView.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 19.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import UIKit

class TrackInfoBlurView: UIVisualEffectView {

    let infoTitle: UILabel = {
        let label = UILabel()
        label.font = AppFont.Title.sml
        label.textColor = .black
        label.backgroundColor = .clear
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 2
        label.text = "Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго Виктор Гюго "
        label.sizeToFit()
        return label
    }()
    
    let infoText: UITextView = {
        let textView = UITextView()
        textView.font = AppFont.Title.info
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.text = "Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин  Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин Максимилиан Волошин "
        return textView
    }()
    
    convenience init()
    {
        self.init(effect: UIBlurEffect.init(style: UIBlurEffectStyle.light))
        
        self.viewInitialize()
    }
    
    func viewInitialize()
    {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.clipsToBounds = true
        self.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        self.layer.cornerRadius = 5
        
        self.contentView.addSubview(infoTitle)
        self.contentView.addSubview(infoText)

        infoText.setContentHuggingPriority(.init(999), for: .vertical)
        
        self.alpha = 0
    }
    
    func set(track: TrackViewModel)
    {
        self.infoTitle.text = track.name
        self.infoText.text = track.description
    }
    
    func set(title: String, infoText: String)
    {
        self.infoTitle.text = title
        self.infoText.text = infoText
        
        self.setConstraints()
        self.getInfo(toHide: false, animated: true)
    }
    
    func setConstraints()
    {
        infoTitle.snp.makeConstraints { (make) in
            make.top.equalTo(self.frame.origin.y).inset(50)
            make.left.equalTo((superview?.snp.left)!).inset(20)
            make.right.equalTo((superview?.snp.right)!).inset(10)
        }

        infoText.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).inset(-12)
            make.bottom.equalTo(self.frame.size.height - self.frame.origin.y).inset(-10)
            make.left.equalTo((superview?.snp.left)!).inset(10)
            make.right.equalTo((superview?.snp.right)!).inset(10)
        }
    }
    
    func getInfo(toHide: Bool, animated: Bool)
    {
        if toHide
        {
            if animated
            {
                UIView.animate(withDuration: 0.5, animations: {
                    self.alpha = 0
                })
            }
            else
            {
                self.alpha = 0
            }
        }
        else
        {
            self.infoText.setContentOffset(.zero, animated: false)
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1
            })
        }
    }
}
