Pod::Spec.new do |spec|

  spec.name         = "AKNetworkManager"
  spec.version      = "0.0.10"
  spec.summary      = "Network Manager"
  spec.description  = "A wrapper class for network manager."
  spec.homepage     = "https://www.hexalitics.com"
  spec.license      = "MIT"
  spec.author       = { "Amit Garg" => "09s.amitgarg@gmail.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/09samit/AKNetworkManager.git", :tag => "#{spec.version}" }
  spec.swift_version = "4.2"
  spec.source_files  = ["Source/**/*.{swift}", "AKNetworkManager/**/*.swift"]
  spec.dependency "Alamofire", '5.6.4'
end
