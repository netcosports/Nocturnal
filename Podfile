
use_modular_headers!
#use_frameworks!
inhibit_all_warnings!

install! 'cocoapods', :disable_input_output_paths => true

platform :ios, '11.0'

target 'Demo' do

  pod 'Astrolabe', :git => 'git@github.com:netcosports/Astrolabe.git', :branch => 'kmm'
  pod 'Sundial', :git => 'git@github.com:netcosports/Sundial.git', :branch => 'kmm'

  pod 'Nocturnal', :path => '.'
  pod 'Nocturnal/NavigationBar', :path => '.'
  pod 'Nocturnal/ContainerView', :path => '.'

  pod 'PinLayout'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|

    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'

      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
      if config.name == 'Debug'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        else
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end
