require 'rbconfig'
require 'singleton'
require 'machine_nics/logger'
require 'machine_nics/actions/linux'
require 'machine_nics/actions/test'
require 'machine_nics/actions/freebsd'

module MachineNics
  class Actions
    include MachineNics
    def initialize(type)
      @type = type || 'Test'
      case @type
      when /test/i
        self.extend MachineNics::Actions::Test
      when /freebsd/i
        self.extend MachineNics::Actions::Freebsd
      when /linux/i
        self.extend MachineNics::Actions::Linux
      end
    end
    def self.list_types
      return "Test, " + "Freebsd, " + "Linux"
    end
    def vid_from_name(name)
      # several vlan with the same vid but not the same name:
      # vlan10100 vlan10101, ...
      vid = nil
      if name.to_s.length > 8
        l = name.to_s.length - 2 - 4
        vid = name.to_s[4,l]
      else
        vid = name.to_s.gsub(/\D+/,'')
      end
      vid
    end

    def name_mtu_from(name)
      name.to_s.match(/(^[^_]+)(?:_(.*))?/).to_a[1,2]
    end

    def dispatch(cmd, nic, members = [])
      function = nic.to_s.sub(/^(?:\/dev\/)?([^0-9_]+)[\d_]+/,'\1')
      name, mtu = name_mtu_from(nic)
#      name ||= nic
      mtu ||= 1500
      vid = nil
      if nic.to_s =~ /vlan/i
        vid = vid_from_name(nic.to_s)
      end
      nics = members.map {|nic| name_mtu_from(nic)[0]}
      params = {name: name, mtu: mtu, vid: vid, members: nics}
      if cmd.to_s =~ /destroy/
        if send(function + '_' + 'empty?', params)
          return send(function + '_' + cmd, params)
        else
          []
        end
      elsif cmd.to_s =~ /create/
        post_cmd = send(function + '_' + 'up', params)
        [ send(function + '_' + cmd, params), post_cmd ]
      end
    end
  end
end
