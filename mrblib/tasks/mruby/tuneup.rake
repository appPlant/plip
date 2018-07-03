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

namespace :mruby do
  desc 'optimize build'
  task tuneup: 'mruby:environment' do
    args = "#{ARGV.join(' ')} local=#{ENV['MRUBY_CLI_LOCAL'].to_i}"

    MRuby.targets.keep_if do |name, spec|
      case args
      when /local=1/ then name == 'host'
      when /compile/ then name != 'host' || !in_a_docker_container?
      when /bintest/ then spec.bintest_enabled?
      when /test/    then spec.bintest_enabled? || spec.test_enabled?
      else                true
      end
    end

    Rake::Task['mruby:all'].prerequisites.keep_if do |p|
      MRuby.targets.any? { |n, _| p =~ %r{mruby/bin|/#{n}/} }
    end
  end
end
