'EOF'
def install_all_flutter_pods(flutter_application_path)
  # Install Flutter framework
  pod 'Flutter', :path => File.join(flutter_application_path, 'Flutter')
  
  # Install Flutter plugins
  plugins_file = File.join(flutter_application_path, '.flutter-plugins')
  if File.exist?(plugins_file)
    File.readlines(plugins_file).each do |line|
      plugin = line.strip
      next if plugin.empty?
      name, path = plugin.split('=')
      pod name, :path => File.join(flutter_application_path, path, 'ios') if name && path
    end
  end
end

def flutter_additional_ios_build_settings(installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
EOF