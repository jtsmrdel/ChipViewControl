Pod::Spec.new do |s|

  s.name         = "ChipViewControl"
  s.version      = "1.4.2"
  s.summary      = "A simple auto-sizing, scrollable, chip view control for iOS"
  s.swift_version = "5.0"
  s.description  = <<-DESC
A simple auto-sizing, scrollable, chip view control for iOS.
                   DESC
  s.homepage     = "https://github.com/jtsmrd/ChipViewControl"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "JT Smrdel" => "jtsmrdel@gmail.com" }
  s.platform     = :ios
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/jtsmrd/ChipViewControl.git", :tag => "#{s.version}" }
  s.source_files  = "ChipViewControl/**/*.{swift}"
  s.framework  = "UIKit"
  s.requires_arc = true

end
