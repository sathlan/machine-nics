Feature: Destroy Freebsd network
  Scenario: Display the necessary steps to destroy a simple Freebsd network.
    Given a file named "desc-simple-freebsd.yaml" with:
    """
    :machine-1:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a destroy -t Freebsd -f desc-simple-freebsd.yaml -n`
    Then it should pass with:
      """
        => Destroy TAP202_1496 using:
          * sudo ifconfig tap202 destroy
        => Destroy TAP201_1496 using:
          * sudo ifconfig tap201 destroy
      """

  Scenario: Display the necessary steps to destroy a bridged Freebsd network.
    Given a file named "desc-bridge-freebsd.yaml" with:
    """
    :machine-1:
      :bridge0:
      - :tap201_1496
      - :tap202_1496
    """
    When I run `machine-nics -a destroy -t Freebsd -f desc-bridge-freebsd.yaml -n`
    Then it should pass with:
    """
        => Destroy TAP202_1496 using:
          * sudo ifconfig tap202 destroy
        => Destroy TAP201_1496 using:
          * sudo ifconfig tap201 destroy
      => Destroy BRIDGE0 using:
        * sudo ifconfig bridge0 destroy
    """

  Scenario: Display the necessary steps to destroy a bonding in Freebsd network.
    Given a file named "desc-bond-freebsd.yaml" with:
    """
    :machine-1:
      :lagg0:
      - :tap101_1496
      - :tap102_1496
    """
    When I run `machine-nics -a destroy -t Freebsd -f desc-bond-freebsd.yaml -n`
    Then it should pass with:
    """
        => Destroy TAP102_1496 using:
          * sudo ifconfig tap102 destroy
        => Destroy TAP101_1496 using:
          * sudo ifconfig tap101 destroy
      => Destroy LAGG0 using:
        * sudo ifconfig lagg0 destroy
    """

  Scenario: Display the necessary steps to destroy a vlan in Freebsd network.
    Given a file named "desc-vlan-freebsd.yaml" with:
    """
    :machine-1:
      :vlan101: :tap101
    """
    When I run `machine-nics -a destroy -t Freebsd -f desc-vlan-freebsd.yaml -n`
    Then it should pass with:
    """
        => Destroy TAP101 using:
          * sudo ifconfig tap101 destroy
      => Destroy VLAN101 using:
        * sudo ifconfig vlan101 destroy
    """

  Scenario: Display the step to destroy a complex network in Freebsd
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
    When I run `machine-nics -a destroy -t Freebsd -f desc-complex-freebsd.yaml -n`
    Then it should pass with:
    """
          => Destroy TAP102_1496 using:
            * sudo ifconfig tap102 destroy
          => Destroy TAP101_1496 using:
            * sudo ifconfig tap101 destroy
        => Destroy LAGG0 using:
          * sudo ifconfig lagg0 destroy
        => Destroy TAP202_1496 using:
          * sudo ifconfig tap202 destroy
        => Destroy TAP201_1496 using:
          * sudo ifconfig tap201 destroy
      => Destroy BRIDGE0 using:
        * sudo ifconfig bridge0 destroy
        => Destroy TAP101 using:
          * sudo ifconfig tap101 destroy
      => Destroy VLAN101 using:
        * sudo ifconfig vlan101 destroy
    """
