Pod::Spec.new do |s|

    s.name = 'Reditor'
    s.version = '1.0.4'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.summary = 'A Reditor is simple photo editor.'
    s.homepage = 'https://github.com/iOS-Ninja/Reditor'
    s.author = { 'iOS Ninja' => 'dev.igormak@gmail.com' }
    s.platform = :ios
    s.ios.deployment_target = '10.0'
    s.swift_version = '4.0'
    s.requires_arc = true
    s.source = { :git => 'https://github.com/iOS-Ninja/Reditor.git', :tag => s.version.to_s  }
    s.source_files = 'Reditor/**/*.{swift}'
    s.resources = 'Reditor/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}'

end
