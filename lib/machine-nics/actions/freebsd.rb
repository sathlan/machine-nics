module MachineNics
  class Actions
    module Freebsd
      def lagg_create(params)
        cmd = "sudo ifconfig #{params[:name]} create mtu #{params[:mtu]} laggproto loadbalance"
        params[:members].each do |nic|
          cmd += " laggport #{nic}"
        end
        [cmd]
      end
      def vlan_create(params)
        cmd = ["sudo ifconfig #{params[:name]} create vlan #{params[:vid]} vlandev #{params[:members].first}"]
      end

      def bridge_create(params)
        cmd_before = "sudo ifconfig #{params[:name]} create 2>/dev/null;"
        cmd_pre = "sudo ifconfig #{params[:name]} "
        cmds = []
        params[:members].each do |nic|
          cmds << "#{cmd_pre} addm #{nic}"
        end
        cmd = [cmd_before, cmds]
      end

      def tap_create(params)
        mtu = params[:mtu]
        name_without_mtu = params[:name]
        cmd = ["sudo ifconfig #{name_without_mtu} create mtu #{mtu}"]
      end

      def up(params)
        cmd = "sudo ifconfig #{params[:name]} up"
        [ cmd ]
      end
      alias :lagg_up :up
      alias :vlan_up :up
      alias :bridge_up :up
      alias :tap_up :up

      def destroy(params)
        cmd = "sudo ifconfig #{params[:name]} destroy"
        [ cmd ]
      end
      alias :lagg_destroy :destroy
      alias :vlan_destroy :destroy
      alias :bridge_destroy :destroy
      alias :tap_destroy :destroy
      def tap_empty?(name)
        true
      end

      def lagg_empty?(params)
        composite_empty?(params[:name], 'laggport')
      end
      def bridge_empty?(params)
        composite_empty?(params[:name], 'member')
      end
      def vlan_empty?(params)
        true
      end
      def composite_empty?(name, port_name)
        cmd = %Q{ifconfig #{name} | awk '/#{port_name}:/{print $2}'}
        `#{cmd}`.split.empty?
      end

    end
  end
end
