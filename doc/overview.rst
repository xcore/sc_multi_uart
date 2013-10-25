Overview
========

This module provides a software library that allows multiple uarts to share 8 bit ports for multiple channel UART communication. It is dynamically re-configurable for applications that require a level of flexibility during operation.

Features
--------

Multi UART component provides the following functionality. All options are dynamically reconfigurable via the API.

.. list-table::
    :header-rows: 1
    
    * - Function
      - Operational Range
      - Notes
    * - Baud Rate
      - 150 to 115200 bps
      - Dependent on clocking (see :ref:`sec_ext_clk`)
    * - Parity
      - None, Mark, Space, Odd, Even
      - 
    * - Stop Bits
      - 1,2
      -
    * - Data Length
      - 1 to 30 bits
      - Max 30 bits assumes 1 stop bit and no parity.

sliceKIT compatibility (XA-SK-UART8) 
------------------------------------

.. image:: images/Square-Triangle-Star.png
    :align: left


This module is designed to work with the XA-SK-UART8 sliceCARD which has the slot compatitbility shown above.


