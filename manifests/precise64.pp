stage { 'first': before  => Stage['main'] }
stage { 'last':  require => Stage['main'] }
stage { 'pre': before => Stage['first'] }

class {
      'apt_update':     stage => pre;
      'system':         stage => first;     
      'python_modules': stage => main;
      'ruby_modules':   stage => main;
      'post_python_modules': stage => last;
      'cronjobs':	stage=> last;
      'sass-watch':	stage=> last;
}

include postgresql::server
postgresql::db{ 'grondviewdb':
  user          => 'grondview',
  password      => 'grondview',
  grant         => 'all',
}


# Run apt-get update once on VM creation
# -----------------------------
class apt_update { 
  exec {
     "apt-get update":
        command => "/usr/bin/apt-get update && touch /root/apt-updated",
        creates => "/root/apt-updated";
       }
}

# System packages via apt
#------------------------------
class system{
  package {
      "build-essential":
          ensure => installed,
          provider => apt;
      "python":
          ensure => installed,
          provider => apt;
      "python-dev":
          ensure => installed,
          provider => apt;
      "python-pip":
          ensure => installed,
          provider => apt;
      "rubygems":
          ensure => installed,
          provider => apt;
      "libpq-dev":
          ensure => installed,
          provider => apt;
      "git":
          ensure => installed,
          provider => apt;
      "python-matplotlib":
          ensure => installed,
          provider => apt;
      "python-scipy":
          ensure => installed,
          provider => apt;
  }
}

# Python modules via pip
#------------------------------
class python_modules{
  package {
      "numpy":
          ensure => "1.6.1",
          provider => pip;
      "pyfits":
          ensure => "2.4.0",
          provider => pip;
      "django":
          ensure => "1.4.3",
          provider => pip;

  }
}
class post_python_modules{
  package{
       "astLib":
          ensure => "0.6.1",
          provider => pip;

#      "astropy":
#          ensure => "0.1",
#          provider => pip;

      "psycopg2":
          ensure => "2.4.6",
          provider => pip;
        }
  

  exec {
     "mpl-rc":
        command => "/bin/mkdir /home/vagrant/.matplotlib && /bin/echo 'backend: agg' > /home/vagrant/.matplotlib/matplotlibrc",
        creates => "/home/vagrant/.matplotlib/matplotlibrc",
        user => vagrant;
       }

}



# cron jobs
#----------------------------
class cronjobs{
  cron { "purge_media":
           command => "/usr/bin/python /home/vagrant/grondview/utils/purge_media.py >~/grondview/logs/cron.log 2>&1",
           user => vagrant,
           ensure => present,
           minute => "*/5"
  }
}



# Ruby packages via gem
#------------------------------
class ruby_modules{
  package{
      "sass":
        ensure => installed,
        provider => gem;
  }
}

class sass-watch{
  exec {
   "sass-watch":
       command => "/usr/local/bin/sass --watch /home/vagrant/grondview/grondview/static/css/sass/style.scss:/home/vagrant/grondview/grondview/static/css/style.css >/dev/null &",
       user => vagrant;
       }
}
