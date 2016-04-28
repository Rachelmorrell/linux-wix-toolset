$target = '/usr/share/wix'
$source = 'http://static.wixtoolset.org/releases/v4.0.3922.0/wix40-binaries.zip'

file { 'WiX dir':
  ensure => directory,
  path   => $target,
}

package { 'unzip': }
package { 'epel-release': }
->
package { ['mono-core','wine']: }

staging::deploy { 'wix40-binaries.zip':
  source  => $source,
  target  => $target,
  require => [
    Package['unzip'],
    File['WiX dir'],
  ],
  creates => "${target}/swc.exe",
}
