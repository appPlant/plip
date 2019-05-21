# Apache 2.0 License
#
# Copyright (c) 2018 Sebastian Katzer, appPlant GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

def gem_config(conf, glibc_version: '2.19', with_openssl: false)
  conf.cc.defines += %w[MBEDTLS_THREADING_PTHREAD MBEDTLS_THREADING_C]
  conf.cc.defines += %w[LIBSSH2_HAVE_ZLIB HAVE_UNISTD_H]

  configure_glibc(conf, glibc_version)
  configure_openssl(conf) if with_openssl

  conf.gem __dir__
end

def configure_openssl(conf)
  conf.cc.defines += %w[MRB_SSH_LINK_CRYPTO LIBSSH2_OPENSSL]
  conf.linker.libraries << 'crypto'
end

def configure_glibc(conf, ver)
  return if !ENV['GLIBC_HEADERS'] || conf.is_a?(MRuby::CrossBuild)

  [conf.cc, conf.cxx].each do |cc|
    cc.flags << "-include #{ENV['GLIBC_HEADERS']}/x64/force_link_glibc_#{ver}.h"
  end
end

MRuby::Build.new do |conf|
  toolchain ENV.fetch('TOOLCHAIN', :clang)

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  gem_config(conf)
end

MRuby::Build.new('x86_64-pc-linux-gnu') do |conf|
  toolchain :clang

  [conf.cc, conf.cxx, conf.linker].each do |cc|
    cc.flags << '-Oz'
  end

  gem_config(conf)
end

MRuby::Build.new('x86_64-pc-linux-gnu-glibc-2.9') do |conf|
  toolchain :clang

  [conf.cc, conf.cxx, conf.linker].each do |cc|
    cc.flags << '-Oz'
  end

  gem_config(conf, glibc_version: '2.9')
end

MRuby::Build.new('x86_64-pc-linux-gnu-openssl') do |conf|
  toolchain :clang

  [conf.cc, conf.cxx, conf.linker].each do |cc|
    cc.flags << '-Oz'
  end

  gem_config(conf, with_openssl: true)
end

MRuby::CrossBuild.new('x86_64-alpine-linux-musl') do |conf|
  toolchain :gcc

  [conf.cc, conf.linker].each do |cc|
    cc.command = 'musl-gcc'
    cc.flags << '-Os'
  end

  gem_config(conf)
end

MRuby::CrossBuild.new('x86_64-apple-darwin15') do |conf|
  toolchain :clang

  [conf.cc, conf.linker].each do |cc|
    cc.command = 'x86_64-apple-darwin15-clang'
    cc.flags  += %w[-Oz -mmacosx-version-min=10.11 -stdlib=libstdc++]
  end

  conf.cxx.command      = 'x86_64-apple-darwin15-clang++'
  conf.archiver.command = 'x86_64-apple-darwin15-ar'

  conf.build_target     = 'x86_64-pc-linux-gnu'
  conf.host_target      = 'x86_64-apple-darwin15'

  gem_config(conf)
end

MRuby::CrossBuild.new('x86_64-w64-mingw32') do |conf|
  toolchain :gcc

  [conf.cc, conf.linker].each do |cc|
    cc.command = 'x86_64-w64-mingw32-gcc'
    cc.flags += %w[-Os -DPCRE_STATIC]
  end

  conf.cxx.command      = 'x86_64-w64-mingw32-cpp'
  conf.archiver.command = 'x86_64-w64-mingw32-gcc-ar'
  conf.exts.executable  = '.exe'

  conf.build_target     = 'x86_64-pc-linux-gnu'
  conf.host_target      = 'x86_64-w64-mingw32'

  gem_config(conf)
end
