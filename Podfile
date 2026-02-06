# Uncomment the next line to define a global platform for your project
deployment_target = '26.0'
platform :ios, deployment_target

source 'https://git.csez.zohocorpin.com/vtouchzoho/vtouchpodspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'record' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'VTDB/SQLCipher'
  pod 'SQLCipher', '4.5.7', :modular_headers => true
  # Pods for record

  target 'recordTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'recordUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = deployment_target
    end
  end
end
