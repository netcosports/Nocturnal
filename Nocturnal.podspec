Pod::Spec.new do |s|
  s.name = 'Nocturnal'
  s.version = '0.1.0'
  s.summary = 'rx-based MVVM-C componets'

  s.homepage = 'https://github.com/netcosports/Nocturnal'
  s.license = { :type => "MIT" }
  s.author = {
    'Sergei Mikhan' => 'sergei@netcosports.com'
  }
  s.source = { :git => 'https://github.com/netcosports/Nocturnal.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_versions = ['5.0', '5.1']
  s.default_subspec = 'Core'

  s.subspec 'Core' do |sub|
    sub.source_files = 'Sources/Core/*.swift'

    sub.dependency 'RxSwift', '~> 5'
    sub.dependency 'RxCocoa', '~> 5'
    sub.dependency 'RxGesture'

    sub.dependency 'Astrolabe', '~> 5'
    sub.dependency 'Alidade', '~> 5'
    sub.dependency 'Sundial', '~> 5'
  end
end
