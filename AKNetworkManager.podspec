Pod::Spec.new do |spec|

  spec.name         = "AKNetworkManager"
  spec.version      = "0.0.1"
  spec.summary      = "Network Manager"
  spec.description  = "A wrapper class for network manager."
  spec.homepage     = "https://github.com/09samit/AKNetworkManager.git"
  spec.license      = "MIT (example)"
  spec.author             = { "Amit Garg" => "09s.amitgarg@gmail.com" }
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/09samit/AKNetworkManager.git", :tag => "#{spec.version}" }
  spec.source_files  = "AKNetworkManager/**/*.swift"

end