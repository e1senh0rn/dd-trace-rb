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

  MACOS_INTEGER_T = :int      # https://github.com/apple/darwin-xnu/blob/main/osfmk/mach/i386/vm_types.h#L93
  MACOS_POLICY_T = :int       # https://github.com/apple/darwin-xnu/blob/main/osfmk/mach/policy.h#L79

  class StructTimeValue < FFI::Struct
    layout(
      seconds: MACOS_INTEGER_T,
      microseconds: MACOS_INTEGER_T,
    )
  end

  class MachMsgTypeNumberT < FFI::Struct
    layout(
      fixme: :uint,
    )
  end

  MACOS_TIME_VALUE_T = StructTimeValue

  class StructThreadBasicInfo < FFI::Struct
    # https://github.com/apple/darwin-xnu/blob/main/osfmk/mach/thread_info.h#L92
    layout(
      user_time:     MACOS_TIME_VALUE_T,
      system_time:   MACOS_TIME_VALUE_T,
      cpu_usage:     MACOS_INTEGER_T,
      policy:        MACOS_POLICY_T,
      run_state:     MACOS_INTEGER_T,
      flags:         MACOS_INTEGER_T,
      suspend_count: MACOS_INTEGER_T,
      sleep_time:    MACOS_INTEGER_T,
    )
  end

  attach_function(
    :mach_thread_self, # http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/mach_thread_self.html
                       # https://github.com/apple/darwin-xnu/blob/8f02f2a044b9bb1ad951987ef5bab20ec9486310/libsyscall/mach/mach/mach_init.h#L73
    [],                # no args
    :uint,             # mach_port_t => __darwin_mach_port_t => __darwin_mach_port_name_t => __darwin_natural_t => unsigned int
  )
  attach_function(
    :thread_info,      # https://github.com/apple/darwin-xnu/blob/main/osfmk/mach/thread_act.defs#L241
                       # https://developer.apple.com/documentation/kernel/1418630-thread_info
    [
      :uint,           # thread_inspect_it => mach_port_t => (see above)
      :uint,           # thread_flavor_t => natural_t => __darwin_natural_t => (see above)
      StructThreadBasicInfo.by_ref,
      MachMsgTypeNumberT.by_ref,         # mach_msg_type_number_t *thread_info_outCnt
    ],
    :int,              # kern_return_t
  )

  THREAD_BASIC_INFO = 3 # https://github.com/apple/darwin-xnu/blob/main/osfmk/mach/thread_info.h#L90
end

current_thread_port = MacStuff.mach_thread_self

thread_basic_info = MacStuff::StructThreadBasicInfo.new
thread_info_out_cnt = MacStuff::MachMsgTypeNumberT.new

MacStuff.thread_info(current_thread_port, MacStuff::THREAD_BASIC_INFO, thread_basic_info, thread_info_out_cnt)

puts thread_basic_info.inspect

binding.pry
