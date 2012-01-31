require 'rbconfig'
require 'singleton'
require 'machine-nics/logger'
require 'machine-nics/actions/linux'
require 'machine-nics/actions/test'
require 'machine-nics/actions/freebsd'

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
      else
        throw "Cannot find a working type for #{@type}"
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
      mtu ||= infer_mtu_from_child(members)
      vid = nil
      if nic.to_s =~ /vlan/i
        vid = vid_from_name(nic.to_s)
      end
      nics = members.map {|nic| name_mtu_from(nic)[0]}
      params = {name: name, mtu: mtu, vid: vid, members: nics}
      if cmd.to_s =~ /destroy/
        [send(function + '_' + cmd, params)]
      elsif cmd.to_s =~ /create/
        post_cmd = send(function + '_' + 'up', params)
        [ send(function + '_' + cmd, params), post_cmd ]
      end
    end

    def create(nic, members)
      dispatch('create', nic, members)
    end

    def create!(nic, members)
      cmds = create(nic,members)
      cmds.flatten.each {|c| `#{c} 2>/dev/null`}
    end

    def display(action, nic, level, members)
      chosen_level = level || 0

      cmds = dispatch(action, nic, members)
      cmds.flatten.each {|c| puts "  "*level + "  * #{c}"}
    end

    def destroy(nic, members)
      dispatch('destroy', nic, members)
    end

    def destroy!(nic, members)
      cmds = destroy(nic,members)
      cmds.flatten.each {|c| `#{c} 2>/dev/null`}
    end

    def infer_mtu_from_child(nics)
      return 1500 if nics.empty?
      nics.map {|nic|(name_mtu_from(nic)[1].to_i || 1500) }.min
    end
  end
end
