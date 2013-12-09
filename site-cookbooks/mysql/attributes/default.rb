###
# Install Settings
###

# Version
default['mysql']['version'] = "mysql-5.6.15"

# Remote
default['mysql']['remote_url'] = "http://dev.mysql.com/get/Downloads/MySQL-5.6/#{mysql['version']}.tar.gz"

# Directory
default['mysql']['src_dir'] = "/usr/local/src/"
default['mysql']['mysql_dir'] = "/usr/local/mysql/"

# User
default['mysql']['install_user'] = "root"
default['mysql']['install_group'] = "root"

default['mysql']['run_user'] = "mysql"
default['mysql']['run_group'] = "mysql"

# Cmake Options
default['mysql']['cmake'] = %W{-DCMAKE_INSTALL_PREFIX=#{mysql['mysql_dir']}
				-DDEFAULT_CHARSET=utf8
				-DDEFAULT_COLLATION=utf8_unicode_ci}


