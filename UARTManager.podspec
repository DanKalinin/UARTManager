#
# Be sure to run `pod lib lint UARTManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

# Root specification
s.name             = "UARTManager"
s.version          = "0.1.0"
s.author           = { "DanKalinin" => "daniil5511@gmail.com" }
s.license          = 'MIT'
s.homepage         = "https://github.com/DanKalinin/UARTManager"
s.source           = { :git => "https://github.com/DanKalinin/UARTManager.git", :tag => s.version.to_s }
s.summary          = "UART-communication library over Bluetooth."
s.description      = <<-DESC
                     UARTManager presents the UART-communication library over Bluetooth. Some BLE SoCs, such as nRF51 series from Nordic Semiconductor include on-board UART profile which allows to use BLE as UART bus. This profile is presented by UART service and by TX and RX characteristics.
                     Features:
                     * Library provides a complete solution to communicate with Nordic BLE chips over UART.
                     * Vendors can implement their own protocol over UART profile using the system of commands and responses to them.
                     * Library provides UARTCommand class allowing to easy implement own command system by overriding - isRXPacket:responseToTXPacket: method.
                     * Command roundtrip time measurement with up to nanosecond accuracy. Precise system timing functions are used for that.
                     * Modern API providing flexible mechanism of callbacks based on blocks, notifications and delegates. It's up to you which pattern to use.
                     DESC
s.screenshots      = "https://dl.dropbox.com/s/6ffpukyf2fbiugk/Home.PNG",
                     "https://dl.dropbox.com/s/z1xfqureesbwns4/Add%20command.PNG",
                     "https://dl.dropbox.com/s/ufqpttrr90n8lrw/Commands.PNG",
                     "https://dl.dropbox.com/s/50l5hmvvk0e7usx/Results.PNG",
                     "https://dl.dropbox.com/s/wfz84hkgt0de4mp/Failure%20reason.PNG",
                     "https://dl.dropbox.com/s/ielmi7hnbgjeb84/Settings.PNG"

# Platform
s.platform     = :ios, '8.0'

# Build settings
s.requires_arc = true
s.framework = 'UIKit'

# File patterns
s.source_files = 'Pod/Classes/**/*.{h,m}'
s.public_header_files = 'Pod/Classes/**/*.h'

end
