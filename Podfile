# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

def RxSwiftPod
   pod 'RxSwift'
   pod 'RxCocoa'
end

def RIBsPod
   pod 'RIBs', :git => 'https://github.com/uber/RIBs/', :tag => 'v0.10.0' 
end


target 'VideoMerger' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VideoMerger
  pod 'SwiftLint'
  pod 'TLLogging'
  pod 'Resolver'
  pod 'Alamofire'
  pod 'SVProgressHUD'
  pod 'SDWebImage'
  pod 'lottie-ios'
  pod 'DSWaveformImage'
  RxSwiftPod()
  RIBsPod()

end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
