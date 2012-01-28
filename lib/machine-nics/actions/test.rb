module MachineNics
  class Actions
    module Test
      def create(params)
        name = params[:name]
        mtu  = params[:mtu]
        nics = params[:members]
        vid  = params[:vid]
        cmd = "#{name} created with mtu #{mtu}" + (vid ? " and vid #{vid} ": "")
        nics.each do |nic|
          cmd += " using #{nic}"
        end
        [cmd]
      end

      def destroy(params)
        name = params[:name]
        put "PPP: #{pre_cmd}"
        [ pre_cmd, "Destroy #{name}" ]
      end
      def empty?(params)
        log.debug "Testing empty for #{params[:name]}"
        true
      end
      def up(params)
        [ "Setting the interface #{params[:name]} up" ]
      end
      def method_missing(name, *params, &block)
        cmd = []
        case name
        when /_create/
          cmd = create(params[0])
        when /_destroy/
          cmd = destroy(params[0])
        when /_empty\?/
          cmd = empty?(params[0])
        when /_up/
          cmd = up(params[0])
        end
        cmd
      end
    end
  end
end
