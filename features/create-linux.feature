Feature: Create Linux network

  Scenario: Display the necessary steps to create a simple Linux network.
    Given a file named "desc-simple-linux.yaml" with:
    """
    :machine-1:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a create -t Linux -f desc-simple-linux.yaml -n`
    Then it should pass with:
    """
      => Create TAP202_1496 using:
        * sudo tunctl -t tap202
        * sudo ip l set dev tap202 mtu 1496
        * sudo ip l set dev tap202 up
      => Create TAP201_1496 using:
        * sudo tunctl -t tap201
        * sudo ip l set dev tap201 mtu 1496
        * sudo ip l set dev tap201 up
    """

  Scenario: Display the necessary steps to create a bridged Linux network.
    Given a file named "desc-bridge-linux.yaml" with:
    """
    :machine-1:
      :bridge0:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a create -t Linux -f desc-bridge-linux.yaml -n`
    Then it should pass with:
    """
        => Create TAP202_1496 using:
          * sudo tunctl -t tap202
          * sudo ip l set dev tap202 mtu 1496
          * sudo ip l set dev tap202 up
        => Create TAP201_1496 using:
          * sudo tunctl -t tap201
          * sudo ip l set dev tap201 mtu 1496
          * sudo ip l set dev tap201 up
      => Create BRIDGE0 using:
        * sudo brctl addbr bridge0
        * sudo brctl addif bridge0 tap201
        * sudo brctl addif bridge0 tap202
        * sudo ip l set dev bridge0 up
    """

  Scenario: Display the necessary steps to create a bonding in Linux network.
    Given a file named "desc-bond-linux.yaml" with:
    """
    :machine-1:
      :lagg0:
      - :tap101_1496
      - :tap102_1496
    """
    When I run `machine-nics -a create -t Linux -f desc-bond-linux.yaml -n`
    Then it should pass with:
    """
        => Create TAP102_1496 using:
          * sudo tunctl -t tap102
          * sudo ip l set dev tap102 mtu 1496
          * sudo ip l set dev tap102 up
        => Create TAP101_1496 using:
          * sudo tunctl -t tap101
          * sudo ip l set dev tap101 mtu 1496
          * sudo ip l set dev tap101 up
      => Create LAGG0 using:
        * sudo sh -c 'echo "+lagg0" > /sys/class/net/bonding_masters';
        * sudo sh -c 'echo "layer3+4"    > /sys/class/net/lagg0/bonding/xmit_hash_policy'
        * sudo sh -c 'echo balance-xor   > /sys/class/net/lagg0/bonding/mode'
        * sudo sh -c 'echo 100           > /sys/class/net/lagg0/bonding/miimon'
        * sudo ip l set dev lagg0 mtu 1496
        * sudo ip l set dev tap101 down
        * sudo sh -c 'echo +tap101        > /sys/class/net/lagg0/bonding/slaves'
        * sudo ip l set dev tap102 down
        * sudo sh -c 'echo +tap102        > /sys/class/net/lagg0/bonding/slaves'
        * sudo ip l set dev lagg0 up
    """

  Scenario: Display the necessary steps to create a vlan in Linux network.
    Given a file named "desc-vlan-linux.yaml" with:
    """
    :machine-1:
      :vlan10101: :tap102
      :vlan101: :tap101
    """
    When I run `machine-nics -a create -t Linux -f desc-vlan-linux.yaml -n`
    Then it should pass with:
    """
        => Create TAP101 using:
          * sudo tunctl -t tap101
          * sudo ip l set dev tap101 mtu 1500
          * sudo ip l set dev tap101 up
      => Create VLAN101 using:
        * sudo vconfig add tap101 101
        * sudo ip l set dev tap101.101 up
        => Create TAP102 using:
          * sudo tunctl -t tap102
          * sudo ip l set dev tap102 mtu 1500
          * sudo ip l set dev tap102 up
      => Create VLAN10101 using:
        * sudo vconfig add tap102 101
        * sudo ip l set dev tap102.101 up
    """

  Scenario: Display the step to create a complex network in Linux
    Given a file named "desc-complex-linux.yaml" with:
    """
    :machine-1:
      :bridge0:
      - :tap201_1496
      - :tap202_1496
      - :lagg0:
        - :tap101_1496
        - :tap102_1496
      :vlan101: :tap101
    """
    When I run `machine-nics -a create -t Linux -f desc-complex-linux.yaml -n`
    Then it should pass with:
    """
          => Create TAP102_1496 using:
            * sudo tunctl -t tap102
            * sudo ip l set dev tap102 mtu 1496
            * sudo ip l set dev tap102 up
          => Create TAP101_1496 using:
            * sudo tunctl -t tap101
            * sudo ip l set dev tap101 mtu 1496
            * sudo ip l set dev tap101 up
        => Create LAGG0 using:
          * sudo sh -c 'echo "+lagg0" > /sys/class/net/bonding_masters';
          * sudo sh -c 'echo "layer3+4"    > /sys/class/net/lagg0/bonding/xmit_hash_policy'
          * sudo sh -c 'echo balance-xor   > /sys/class/net/lagg0/bonding/mode'
          * sudo sh -c 'echo 100           > /sys/class/net/lagg0/bonding/miimon'
          * sudo ip l set dev lagg0 mtu 1496
          * sudo ip l set dev tap101 down
          * sudo sh -c 'echo +tap101        > /sys/class/net/lagg0/bonding/slaves'
          * sudo ip l set dev tap102 down
          * sudo sh -c 'echo +tap102        > /sys/class/net/lagg0/bonding/slaves'
          * sudo ip l set dev lagg0 up
        => Create TAP202_1496 using:
          * sudo tunctl -t tap202
          * sudo ip l set dev tap202 mtu 1496
          * sudo ip l set dev tap202 up
        => Create TAP201_1496 using:
          * sudo tunctl -t tap201
          * sudo ip l set dev tap201 mtu 1496
          * sudo ip l set dev tap201 up
      => Create BRIDGE0 using:
        * sudo brctl addbr bridge0
        * sudo brctl addif bridge0 tap201
        * sudo brctl addif bridge0 tap202
        * sudo brctl addif bridge0 lagg0
        * sudo ip l set dev bridge0 up
        => Create TAP101 using:
          * sudo tunctl -t tap101
          * sudo ip l set dev tap101 mtu 1500
          * sudo ip l set dev tap101 up
      => Create VLAN101 using:
        * sudo vconfig add tap101 101
        * sudo ip l set dev tap101.101 up
    """
