# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'GetGoing' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'FSPagerView'
  pod 'SwiftyPickerPopover'
  pod 'SQLite.swift'
  # Pods for GetGoing
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end

end
