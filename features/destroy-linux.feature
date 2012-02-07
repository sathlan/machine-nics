Feature: Destroy Linux network

  Scenario: Display the necessary steps to destroy a simple Linux network.
    Given a file named "desc-simple-linux.yaml" with:
    """
    :machine-1:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a destroy -t Linux -f desc-simple-linux.yaml -n`
    Then it should pass with:
    """
      => Destroy TAP202_1496 using:
        * sudo tunctl -d tap202
      => Destroy TAP201_1496 using:
        * sudo tunctl -d tap201
    """

  Scenario: Display the necessary steps to destroy a bridged Linux network.
    Given a file named "desc-bridge-linux.yaml" with:
    """
    :machine-1:
      :bridge0:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a destroy -t Linux -f desc-bridge-linux.yaml -n`
    Then it should pass with:
    """
        => Destroy TAP202_1496 using:
          * sudo tunctl -d tap202
        => Destroy TAP201_1496 using:
          * sudo tunctl -d tap201
      => Destroy BRIDGE0 using:
        * sudo ip link set bridge0 down
        * sudo brctl delbr bridge0
    """

  Scenario: Display the necessary steps to destroy a bonding in Linux network.
    Given a file named "desc-bond-linux.yaml" with:
    """
    :machine-1:
      :lagg0:
      - :tap101_1496
      - :tap102_1496
    """
    When I run `machine-nics -a destroy -t Linux -f desc-bond-linux.yaml -n`
    Then it should pass with:
    """
        => Destroy TAP102_1496 using:
          * sudo tunctl -d tap102
        => Destroy TAP101_1496 using:
          * sudo tunctl -d tap101
      => Destroy LAGG0 using:
        * sudo sh -c 'echo "-lagg0" > /sys/class/net/bonding_masters';
    """

  Scenario: Display the necessary steps to destroy a vlan in Linux network.
    Given a file named "desc-vlan-linux.yaml" with:
    """
    :machine-1:
      :vlan10101: :tap102
      :vlan101: :tap101
    """
    When I run `machine-nics -a destroy -t Linux -f desc-vlan-linux.yaml -n`
    Then it should pass with:
    """
        => Destroy TAP101 using:
          * sudo tunctl -d tap101
      => Destroy VLAN101 using:
        * sudo vconfig rem tap101.101
        => Destroy TAP102 using:
          * sudo tunctl -d tap102
      => Destroy VLAN10101 using:
        * sudo vconfig rem tap102.101
    """

  Scenario: Display the step to destroy a complex network in Linux
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
    When I run `machine-nics -a destroy -t Linux -f desc-complex-linux.yaml -n`
    Then it should pass with:
    """
          => Destroy TAP102_1496 using:
            * sudo tunctl -d tap102
          => Destroy TAP101_1496 using:
            * sudo tunctl -d tap101
        => Destroy LAGG0 using:
          * sudo sh -c 'echo "-lagg0" > /sys/class/net/bonding_masters';
        => Destroy TAP202_1496 using:
          * sudo tunctl -d tap202
        => Destroy TAP201_1496 using:
          * sudo tunctl -d tap201
      => Destroy BRIDGE0 using:
        * sudo ip link set bridge0 down
        * sudo brctl delbr bridge0
        => Destroy TAP101 using:
          * sudo tunctl -d tap101
      => Destroy VLAN101 using:
        * sudo vconfig rem tap101.101
    """
