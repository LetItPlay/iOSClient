//
//  ProfileModel.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 08.02.18.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol ProfileModelProtocol: ModelProtocol {
    func change(image: Data)
    func change(name: String)
    func change(language: String)
    func getData()
    func showHiddenChannels()
}

protocol ProfileModelDelegate: class {
    func reload(name: String, image: Data, language: Language)
    func update(image: Data)
    func update(name: String)
    func update(language: Language)
    func showHiddenChannels()
}

class ProfileModel: ProfileModelProtocol {

    weak var delegate: ProfileModelDelegate?
    
    var disposeBag = DisposeBag()
    
    private let imageName = "profileImage"
    
    init()
    {
        let _ = InAppUpdateManager.shared.subscribe(self)
    }
    
    func getData() {
        delegate?.reload(name: UserSettings.name, image: self.getImage(), language: UserSettings.language)
    }
    
    func getImage() -> Data
    {
        var image = UIImage()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(imageName).png").path
        if FileManager.default.fileExists(atPath: filePath) {
            image = UIImage(contentsOfFile: filePath)!
        }
        
        if image.cgImage == nil
        {
            image = UIImage.init(named: "profilePlaceholder")!
        }
        
        let data = UIImagePNGRepresentation(image)!
        
        return data
    }
    
    func updateImage(image: Data) -> Observable<(Data)>
    {
        return Observable<(Data)>.create({ (observer) -> Disposable in
            
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent("\(self.imageName).png")
                try image.write(to: fileURL, options: .atomic)
                observer.onCompleted()
            } catch
            {
//                observer.onError(RequestError.invalidURL)
            }
            
            return Disposables.create
            {
                print("Profile image saved")
            }
        })
    }
    
    func change(image: Data) {
        self.updateImage(image: image).subscribe( onCompleted: {
                self.delegate?.update(image: self.getImage())
            }).disposed(by: disposeBag)
    }
    
    func change(name: String) {
        UserSettings.name = name
        self.delegate?.update(name: UserSettings.name)
    }
    
    func change(language: String) {
        AnalyticsEngine.sendEvent(event: .langChanged)
        
        let newLanguage: Language = UserSettings.languages.filter({$0.name == language}).first!
        ServerUpdateManager.shared.update(language: newLanguage)
    }
    
    func showHiddenChannels() {
        self.delegate?.showHiddenChannels()
    }
    
    func send(event: LifeCycleEvent) {
        switch event {
        case .initialize:
            self.getData()
        default:
            break
        }
    }
}

extension ProfileModel: SettingsUpdateProtocol {
    func settingsUpdated() {
        self.delegate?.update(language: UserSettings.language)
    }
}
