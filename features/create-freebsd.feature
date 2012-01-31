Feature: Create Freebsd network

  Scenario: Display the necessary steps to create a simple Freebsd network.
    Given a file named "desc-simple-freebsd.yaml" with:
    """
    :machine-1:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a create -t Freebsd -f desc-simple-freebsd.yaml -n`
    Then it should pass with:
      """
        => Create TAP202_1496 using:
          * sudo ifconfig tap202 create mtu 1496
          * sudo ifconfig tap202 up
        => Create TAP201_1496 using:
          * sudo ifconfig tap201 create mtu 1496
          * sudo ifconfig tap201 up
      """

  Scenario: Display the necessary steps to create a bridged Freebsd network.
    Given a file named "desc-bridge-freebsd.yaml" with:
    """
    :machine-1:
      :bridge0:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a create -t Freebsd -f desc-bridge-freebsd.yaml -n`
    Then it should pass with:
    """
        => Create TAP202_1496 using:
          * sudo ifconfig tap202 create mtu 1496
          * sudo ifconfig tap202 up
        => Create TAP201_1496 using:
          * sudo ifconfig tap201 create mtu 1496
          * sudo ifconfig tap201 up
      => Create BRIDGE0 using:
        * sudo ifconfig bridge0 create 2>/dev/null;
        * sudo ifconfig bridge0  addm tap201
        * sudo ifconfig bridge0  addm tap202
        * sudo ifconfig bridge0 up
    """

  Scenario: Display the necessary steps to create a bonding in Freebsd network.
    Given a file named "desc-bond-freebsd.yaml" with:
    """
    :machine-1:
      :lagg0:
      - :tap101_1496
      - :tap102_1496
    """
    When I run `machine-nics -a create -t Freebsd -f desc-bond-freebsd.yaml -n`
    Then it should pass with:
    """
        => Create TAP102_1496 using:
          * sudo ifconfig tap102 create mtu 1496
          * sudo ifconfig tap102 up
        => Create TAP101_1496 using:
          * sudo ifconfig tap101 create mtu 1496
          * sudo ifconfig tap101 up
      => Create LAGG0 using:
        * sudo ifconfig lagg0 create mtu 1496 laggproto loadbalance laggport tap101 laggport tap102
        * sudo ifconfig lagg0 up
    """

  Scenario: Display the necessary steps to create a vlan in Freebsd network.
    Given a file named "desc-vlan-freebsd.yaml" with:
    """
    :machine-1:
      :vlan10101: :tap102
      :vlan101: :tap101
    """
    When I run `machine-nics -a create -t Freebsd -f desc-vlan-freebsd.yaml -n`
    Then it should pass with:
    """
        => Create TAP101 using:
          * sudo ifconfig tap101 create mtu 1500
          * sudo ifconfig tap101 up
      => Create VLAN101 using:
        * sudo ifconfig vlan101 create vlan 101 vlandev tap101
        * sudo ifconfig vlan101 up
        => Create TAP102 using:
          * sudo ifconfig tap102 create mtu 1500
          * sudo ifconfig tap102 up
      => Create VLAN10101 using:
        * sudo ifconfig vlan10101 create vlan 101 vlandev tap102
        * sudo ifconfig vlan10101 up
    """

  Scenario: Display the step to create a complex network in Freebsd
    Given a file named "desc-complex-freebsd.yaml" with:
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
    When I run `machine-nics -a create -t Freebsd -f desc-complex-freebsd.yaml -n`
    Then it should pass with:
    """
          => Create TAP102_1496 using:
            * sudo ifconfig tap102 create mtu 1496
            * sudo ifconfig tap102 up
          => Create TAP101_1496 using:
            * sudo ifconfig tap101 create mtu 1496
            * sudo ifconfig tap101 up
        => Create LAGG0 using:
          * sudo ifconfig lagg0 create mtu 1496 laggproto loadbalance laggport tap101 laggport tap102
          * sudo ifconfig lagg0 up
        => Create TAP202_1496 using:
          * sudo ifconfig tap202 create mtu 1496
          * sudo ifconfig tap202 up
        => Create TAP201_1496 using:
          * sudo ifconfig tap201 create mtu 1496
          * sudo ifconfig tap201 up
      => Create BRIDGE0 using:
        * sudo ifconfig bridge0 create 2>/dev/null;
        * sudo ifconfig bridge0  addm tap201
        * sudo ifconfig bridge0  addm tap202
        * sudo ifconfig bridge0  addm lagg0
        * sudo ifconfig bridge0 up
        => Create TAP101 using:
          * sudo ifconfig tap101 create mtu 1500
          * sudo ifconfig tap101 up
      => Create VLAN101 using:
        * sudo ifconfig vlan101 create vlan 101 vlandev tap101
        * sudo ifconfig vlan101 up
    """
