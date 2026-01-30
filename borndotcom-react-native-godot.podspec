require "json"
# Load the package.json once so we can reuse its data.
package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# Load the helper that computes the pre‑built path.
require_relative "./prebuilt-utils.rb"

Pod::Spec.new do |s|
  s.name            = "borndotcom-react-native-godot"
  s.version         = package["version"]
  s.summary         = package["summary"]
  s.description     = package["description"]
  s.homepage        = package["homepage"]
  s.license         = package["license"]
  s.platforms       = { :ios => "14.0" }
  s.author          = package["author"]
  s.source          = { :git => package["repository"], :tag => "#{s.version}" }
  s.frameworks = 'AVFAudio'

  # Vendored frameworks are taken from the pre‑built location.
  # Using the helper ensures the path stays in sync with package.json.
  s.vendored_frameworks = [
    File.join(prebuilt_path("libgodot"), "libgodot.xcframework"),
    File.join(prebuilt_path("libgodot-cpp"), "libgodot-cpp.xcframework")
  ]

  s.weak_frameworks = 'libgodot'

  s.subspec 'Common' do |cs|
    cs.header_mappings_dir = 'common/include'
    cs.source_files = ["common/**/*.{h,hpp,c,cpp,inc}"]
  end

  s.source_files    = ["ios/**/*.{h,hpp,cpp,m,mm,swift}"]
  s.header_mappings_dir = 'ios'

  # Fix: Add header search paths for react-native-worklets-core headers
  # The includes in NativeGodotModule.cpp use direct paths like <WKTJsiWorklet.h>
  # See: https://github.com/borndotcom/react-native-godot/issues/28
  s.pod_target_xcconfig = {
    "HEADER_SEARCH_PATHS" => "$(inherited) \"${PODS_ROOT}/../node_modules/react-native-worklets-core/cpp\""
  }

  install_modules_dependencies(s)
end
