module MachineNics
  class Actions
    module Linux
      def lagg_create(params)
        cmds = []
        cmds.push(%Q!sudo sh -c 'echo "+#{params[:name]}" > /sys/class/net/bonding_masters';!)
        cmds.push(%Q!sudo sh -c 'echo "layer3+4"    > /sys/class/net/#{params[:name]}/bonding/xmit_hash_policy'!)
        cmds.push(%Q!sudo sh -c 'echo balance-xor   > /sys/class/net/#{params[:name]}/bonding/mode'!)
        cmds.push(%Q!sudo sh -c 'echo 100           > /sys/class/net/#{params[:name]}/bonding/miimon'!)
        cmds.push(%Q!sudo ip l set dev #{params[:name]} mtu #{params[:mtu]}!)
        params[:members].each do |nic|
          cmds.push(%Q!sudo ip l set dev #{nic} down!)
          cmds.push(%Q!sudo sh -c 'echo +#{nic}        > /sys/class/net/#{params[:name]}/bonding/slaves'!)
        end
        cmds
      end

      def vlan_create(params)
        cmd = ["sudo vconfig add #{params[:members].first} #{params[:vid]}"]
      end

      def bridge_create(params)
        cmds = []
        cmds.push(%Q!sudo brctl addbr #{params[:name]}!)
        params[:members].each do |nic|
          cmds.push("sudo brctl addif #{params[:name]} #{nic}")
        end
        cmds
      end

      def tap_create(params)
        mtu = params[:mtu]
        cmds = []
        cmds.push(%Q!sudo tunctl -t #{params[:name]}!)
        cmds.push(%Q!sudo ip l set dev #{params[:name]} mtu #{params[:mtu]}!)
        cmds
      end

      def tap_destroy(params)
        [ "sudo tunctl -d #{params[:name]}" ]
      end
      def bridge_destroy(params)
        [ "sudo ip l set #{params[:name]} down", "sudo brctl delbr #{params[:name]}"]
      end
      def lagg_destroy(params)
        [ %Q!sudo sh -c 'echo "-#{params[:name]}" > /sys/class/net/bonding_masters';! ]
      end
      def vlan_destroy(params)
        ["sudo vconfig rem #{params[:members].first}.#{params[:vid]}"]
      end

      def tap_empty?(name)
        true
      end
      def up(params)
        cmd = "sudo ip l set dev #{params[:name]} up"
        [ cmd ]
      end
      def vlan_up(params)
        ["sudo ip l set dev #{params[:members].first}.#{params[:vid]} up" ]
      end
      alias :lagg_up :up
      alias :bridge_up :up
      alias :tap_up :up

      def lagg_empty?(params)
        "cat /sys/class/net/#{params[:name]}/bonding/slaves".split.empty?
      end
      def bridge_empty?(params)
        "ls /sys/class/net/#{params[:name]}/brif/".split.empty?
      end
      def vlan_empty?(params)
        true
      end
    end
  end
end
