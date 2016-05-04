$winetricks_src = 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'
$winetricks_dst = '/usr/local/bin/winetricks'
$wine_mono_src = 'http://dl.winehq.org/wine/wine-mono/4.6.2/wine-mono-4.6.2.msi'
$wine_mono_dst = '/var/tmp/wine-mono-4.6.2.msi'
$wine_gecko_src = 'http://dl.winehq.org/wine/wine-gecko/2.44/wine_gecko-2.44-x86.msi'
$wine_gecko_dst = '/var/tmp/wine_gecko-2.44-x86.msi'

package { 'unzip': }
package { 'xorg-x11-server-Xorg': }
package { 'xauth': }
package { 'epel-release': }
->
package { 'wine': }

include display::xvfb

staging::file {
  'winetricks':
    source => $winetricks_src,
    target => $winetricks_dst,
  ;
  'wine-mono':
    source => $wine_mono_src,
    target => $wine_mono_dst,
  ;
  'wine-gecko':
    source => $wine_gecko_src,
    target => $wine_gecko_dst,
  ;
}

file { 'winetricks':
  path    => $winetricks_dst,
  mode    => '0700',
  require => Staging::File['winetricks'],
}

exec { 'Install DotNet 4.5':
  environment =>
  [
    'DISPLAY=:0.0',
    'WINEDLLOVERRIDES=mscoree,mshtml=',
  ],
  command     => "${winetricks_dst} -q dotnet20",
  require     =>
  [
    File['winetricks'],
    Package['wine'],
    Class['display::xvfb'],
  ],
  logoutput   => true,
  timeout     => 0,
  unless      => "${winetricks_dst} | grep -q dotnet20",
}
->
file { 'root wine':
  ensure => 'link',
  path   => '/root/.wine',
  target => '/.wine',
}
->
exec { 'Install wine-mono':
  environment =>
  [
    'DISPLAY=:0.0',
    'WINEDLLOVERRIDES=mscoree,mshtml=',
  ],
  require     =>
  [
    Staging::File['wine-mono'],
    Class['display::xvfb'],
  ],
  command     => "/usr/bin/msiexec /i ${wine_mono_dst}",
  logoutput   => true,
  timeout     => 0,
}
# exec { 'Install wine-gecko':

#   environment =>

#   [

#     'DISPLAY=:0.0',

#     'WINEDLLOVERRIDES=mscoree,mshtml=',

#   ],

#   require     =>

#   [

#     Staging::File['wine-gecko'],

#     Class['display::xvfb'],

#   ],

# command     => "/usr/bin/msiexec /i /p ${wine_gecko_dst}",

#   logoutput   => true,

#   timeout     => 0,

# }
