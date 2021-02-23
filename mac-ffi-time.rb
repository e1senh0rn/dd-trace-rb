require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'ffi'
  gem 'pry'
end

require 'ffi'
require 'pry'

module MacStuff
  extend FFI::Library
  ffi_lib FFI::CURRENT_PROCESS

  attach_function :mach_thread_self, [], :uint32
  #attach_function :thread_info, [], :int
end

Pry.start
