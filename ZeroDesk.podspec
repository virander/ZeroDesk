
Pod::Spec.new do |s|

  s.name         = "ZeroDesk"
  s.version      = "0.0.1"
  s.summary      = "ZeroDesk is used for sending Feedback and crash report."
  s.description  = <<-DESC
                    ZeroDesk is used for sending Feedback and crash report for iOS devices.
                   DESC

  s.homepage     = "https://github.com/virander/ZeroDesk"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author       = { "virander kumar" => "viru.raj248@gmail.com" }
  s.source       = { :git => "https://github.com/virander/ZeroDesk.git", :tag => "0.0.1" }
  s.ios.deployment_target = '9.0' 
  s.source_files = "ZeroDeskExample", "ZeroDeskExample/**/*.{h,m,swift,plist}"

  # s.resource     = "Assets.xcassets"
  # s.resources  = "Resources/*.png"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  s.requires_arc = true

  # s.preserve_path = "${POD_ROOT}/ZeroDesk/ZeroDeskExample-Bridging-Header.h"
  s.xcconfig = { 'SWIFT_OBJC_BRIDGING_HEADER' => '${POD_ROOT}/ZeroDeskExample/ZeroDeskExample-Bridging-Header.h' }

end
