#
# Copyright (c) 2013-2016 by appPlant GmbH. All rights reserved.
#
# @APPPLANT_LICENSE_HEADER_START@
#
# This file contains Original Code and/or Modifications of Original Code
# as defined in and that are subject to the Apache License
# Version 2.0 (the 'License'). You may not use this file except in
# compliance with the License. Please obtain a copy of the License at
# http://opensource.org/licenses/Apache-2.0/ and read it before using this
# file.
#
# The Original Code and all software distributed under the License are
# distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
# EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
# INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
# Please see the License for the specific language governing rights and
# limitations under the License.
#
# @APPPLANT_LICENSE_HEADER_END@

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative ENV.fetch('BUILD_CONFIG', 'build_config.glibc-2.14.rb')
require 'fileutils'

APP_NAME = 'plip'.freeze
APP_ROOT = Dir.pwd.freeze

def release_path
  "#{APP_ROOT}/releases"
end

def build_path
  "#{APP_ROOT}/build"
end

def src_path
  "#{APP_ROOT}/src"
end

def orbit_path
  "#{APP_ROOT}/bintest/orbit"
end

def version_path
  "#{src_path}/version"
end

APP_VERSION = `go run #{version_path}/*.go -v`.freeze

Dir.chdir('lib') { Dir['tasks/*.rake'].each { |file| load file } }

desc 'print version'
task :version do
  puts APP_VERSION
end

desc 'removes artifacts and folders not becessary for a distribution.'
task :clean do
  rm_rf "#{orbit_path}/bin"
  rm_rf build_path
end
