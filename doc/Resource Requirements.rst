Resource Requirements
=====================

This section provides an overview of the required resources of sc_multi_uart component so that the application designer can operate within these constraints accordingly.

Ports
+++++++

The following ports are required for each of the receive and transmit functions - 

.. list-table::
    :header-rows: 1
    
    * - Operation
      - Port Type
      - Number required
      - Direction
      - Port purpose / Notes
    * - Transmit
      - 8 bit port
      - 1
      - Output
      - Data transmission
    * - Transmit
      - 1 bit port
      - 1
      - Input
      - Optional External clocking (see :ref:`sec_ext_clk`)
    * - Receive
      - 8 bit port
      - 1
      - Input
      - Data Receive

Threads
++++++++++

.. list-table::
    :header-rows: 1
    
    * - Operation
      - Thread Count
      - Notes
    * - Receive
      - 1
      - Single thread server, may require application defined buffering thread - requires 62.5MIPS per thread
    * - Transmit
      - 1
      - Single thread server - requires 62.5MIPS per thread

Memory
++++++++++

The following is a summary of memory usage of the component for all functionality utilised by the echo test application when compiled at optimisation level 3. It assumes a TX buffer of 16 slots and operating at the maximum of 8 UART channels. This is deemed to be a guide only and memory usage may differ according how much of the API is utilised.

Stack usage is estimated at 460 bytes.

.. list-table::
    :header-rows: 1
    
    * - Operation
      - Code (bytes)
      - Data (bytes)
      - Total Usage (bytes)
    * - Receive Thread
      - 316
      - 424
      - 740
    * - Receive API
      - 410
      - 0
      - 410
    * - Transmit Thread
      - 1322
      - 940
      - 2262
    * - Transmit API
      - 480
      - 0
      - 480
    * - **Total**
      - **2159**
      - **1364**
      - **3523**

**Note** These values are meant as a guide and are correct as of Jan 24. 2012 - they may change if fixes are implemented or functionality is added.
      
Channel Usage
+++++++++++++++

.. list-table::
    :header-rows: 1
    
    * - Operation
      - Channel Usage & Type
    * - Receive
      - 1 x Streaming Chanend
    * - Transmit
      - 1 x Streaming Chanend

.. _sec_client_timing:

Client Timing Requirements
++++++++++++++++++++++++++++

The application that interfaces to the receive side of UART component must meet the following timing requirement. This requirement is dependent on configuration so the worst case configuration must be accounted for - this means the shortest UART word (length of the start, data parity and stop bits combined).

.. raw:: latex

    \[ \frac{1}{UART\_CHAN\_COUNT \times \left (  \frac{MAX\_BAUD}{MIN\_BIT\_COUNT} \right )} \]
    
Taking an example where the following values are applied -

    * UART_CHAN_COUNT = 8
    * MAX_BAUD = 115200 bps
    * MIN_BIT_COUNT = 10 (i.e 1 Start Bit, 8 data bits and 1 stop bit)
    
The resultant timing requirement is 10.85 |microsec|. This would be defined and constrained using the XTA tool.

.. |microsec| unicode:: U+03BC U+0053
