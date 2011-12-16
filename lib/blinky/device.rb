require 'serialport'

module Blinky
  class Device
    
    attr_accessor :projects, :sp
    
    # Serial port settings
    BAUD_RATE = 9600
    DATA_BITS = 8
    STOP_BITS = 1
    PARITY = SerialPort::NONE
    
    NUM_REGISTERS = 4
    PASS_MASK = 1 # 00000001
    FAIL_MASK = 2 # 00000010
    BUILD_MASK = 3 # 00000011
    
    def initialize(device_name)
      Blinky.log.debug("device_name -> %s" % device_name)
      @sp = SerialPort.new(device_name, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY)
      @projects = []
    end
    
    # Register change handler on give project to write
    def register o
      @projects << o
      o.on_change { write } 
    end
    
    # We can fit 4 projects into a byte (2 bits * 4 projects = 8 bits = 1 byte)
    # Write two bits for each project, left = fail, right = pass, both = building (e.g. failing -> 10, passing -> 01, building => 11)
    # Concat the bytes into a char string and write to the serial port
    def write
      bytes = []
      @projects.each_slice(NUM_REGISTERS) do |chunk|
        byte = 0
        chunk.each{|p| byte = (byte << 2) | (p.passing? ? PASS_MASK : (p.building? ? BUILD_MASK : FAIL_MASK)) }
        bytes.unshift(byte)
      end
      byte_str = bytes.map{|b| (b ^ 0xFF).chr }.join
      Blinky.log.debug('WRITING BYTES -> %s' % byte_str)
      Blinky.log.debug('WRITING BITS -> %s' % byte_str.unpack('B*'))
      @sp.write(byte_str)
    end
    
    def close
      @sp.close
    end
    
  end
end