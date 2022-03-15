# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

target 'PTon' do
  # Comment the next line if you don't want to use dynamic frameworks
post_install do |installer|
  installer.pods_project.targets.each do |target|
	target.build_configurations.each do |config|
		config.build_settings["ONLY_ACTIVE_ARCH"] = "NO"
	end
  end
end
  use_frameworks!

  # Pods for PTon
  pod 'naveridlogin-sdk-ios'
  pod 'KakaoSDK','~>2.8.5'
  pod 'Charts'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Functions'
  pod 'FirebaseAnalytics'
  pod 'GoogleSignIn'
  pod 'MessageKit'
  pod 'Kingfisher'
  pod 'Alamofire'
  pod 'ToastUI'
  pod 'AlertToast'
  pod 'Firebase/Messaging'
  pod 'Firebase/InAppMessaging'
  pod 'Firebase/Firestore'
end
