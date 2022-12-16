//
//  ViewController.swift
//  AKNetworkManagerExample
//
//  Created by Amit Garg on 12/12/22.
//

import UIKit
import Alamofire
import AKNetworkManager
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        getAppSetting { _,_ in
           
        }
    }
}

struct AppSetting: Codable {
  
    var iOSVersion: String = ""
    var isiOSVersionForceToUpdate : Int = 0
    var androidVersion: String = ""
    var isAndroidVersionForceToUpdate : Int = 0
    var isAdsEnabled: Int = 1
    var adURL: String = "http://shmchat.com1111"

    enum CodingKeys: String, CodingKey {
        case iOSVersion = "ios_version"
        case isiOSVersionForceToUpdate = "ios_version_force_update"
        case androidVersion = "android_version"
        case isAndroidVersionForceToUpdate = "android_version_force_update"
        case isAdsEnabled = "ad_enable"
        case adURL = "ad_url"

    }
    
    var isForcedUpdateNeedToTrigger: Bool {
        if isiOSVersionForceToUpdate == 0 {
            return false
        }
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let versionCompare = version.compare(self.iOSVersion, options: .numeric)
        if versionCompare == .orderedAscending {
            return true
        }
        return false
    }
}

extension ViewController {
    func getAppSetting(block: @escaping (AppSetting?, DataError?)->Void) {
        let _ = NetworkManager.shared.request("appSetting", method: .get, isAuthorizationRequired: false, encoding: URLEncoding.default) { (result : DataResult<AppSetting>) in
            switch result {
            case .Success(let object):
                if let data = object.data {
                    block(data, nil)
                }
                break
            case .Failure(let error):
                 block(nil, error)
                break
            }
        }
    }
}
