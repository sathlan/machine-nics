module MachineNics
  class Actions
    module Linux
      def lagg_create(params)
        cmds = []
        cmds.push(%Q!sudo sh -c 'echo "+#{params[:name]}" > /sys/class/net/bonding_masters';!)
        cmds.push(%Q!sudo sh -c 'echo "layer3+4"    > /sys/class/net/#{params[:name]}/bonding/xmit_hash_policy'!)
        cmds.push(%Q!sudo sh -c 'echo balance-xor   > /sys/class/net/#{params[:name]}/bonding/mode'!)
        cmds.push(%Q!sudo sh -c 'echo 100           > /sys/class/net/#{params[:name]}/bonding/miimon'!)
        cmds.push(%Q!sudo ip link set dev #{params[:name]} mtu #{params[:mtu]}!)
        params[:members].each do |nic|
          cmds.push(%Q!sudo ip link set dev #{nic} down!)
          cmds.push(%Q!sudo sh -c 'echo +#{nic}        > /sys/class/net/#{params[:name]}/bonding/slaves'!)
        end
        cmds
      end

      def vlan_create(params)
        cmd = ["sudo vconfig add #{params[:members].first} #{params[:vid]}"]
      end

      # TODO: need to refactore the whole thing: make each nic into a
      # class would be a good start.
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

      def bridge_create(params)
        cmds = []
        cmds.push("[ -d /sys/class/net/#{params[:name]}/ ] || sudo brctl addbr #{params[:name]}")
        params[:members].each do |nic|
          name = nic
          unless name.to_s.index('vlan').nil?
            vid = vid_from_name(name)
            child_name, mtu = name_mtu_from(params[:tree].children[name.to_sym].first.to_s)
            name = "#{child_name}.#{vid}"
          end
          cmds.push("sudo brctl addif #{params[:name]} #{name}")
        end
        cmds
      end

      def tap_create(params)
        mtu = params[:mtu]
        cmds = []
        cmds.push(%Q!sudo tunctl -t #{params[:name]}!)
        cmds.push(%Q!sudo ip link set dev #{params[:name]} mtu #{params[:mtu]}!)
        cmds
      end

      def tap_destroy(params)
        [ "sudo tunctl -d #{params[:name]}" ]
      end
      def bridge_destroy(params)
        [ "sudo ip link set #{params[:name]} down", "sudo brctl delbr #{params[:name]}"]
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
        cmd = "sudo ip link set dev #{params[:name]} up"
        [ cmd ]
      end
      def vlan_up(params)
        ["sudo ip link set dev #{params[:members].first}.#{params[:vid]} up" ]
      end
      alias :lagg_up :up
      alias :bridge_up :up
      alias :tap_up :up

      def lagg_empty?(params)
        `[ -e  /sys/class/net/#{params[:name]}/bonding/ ] && cat /sys/class/net/#{params[:name]}/bonding/slaves`.split.empty?
      end
      def bridge_empty?(params)
        `[ -e  /sys/class/net/#{params[:name]}/brif ] && ls /sys/class/net/#{params[:name]}/brif/`.split.empty?
      end
      def vlan_empty?(params)
        true
      end
    end
  end
end
