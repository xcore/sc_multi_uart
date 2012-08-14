Example Applications
=====================

This section discusses the demonstration application that uses multi-UART component.

Demonstration Application
~~~~~~~~~~~~~~~~~~~~~~~~~

Demo Application Hardware
-------------------------

The echo demonstration application can be run on the slice kit Board. The following other parts are required - 

    * RS232 to COM port cable (provided with slice card package)
    
The demo application is built by default for Slicekit Core Board, SQAURE Connector type. To build for other connectors, choose from the following changes.

To build for CIRCLE connector, make the following changes:

.. list-table::
    :header-rows: 1
    
    * - File
      - Original Value
      - New Value
    * - ``src/main.xc``
      - ``#define SK_MULTI_UART_SLOT_SQUARE 1``
      - ``#define SK_MULTI_UART_SLOT_CIRCLE 1``
    * - ``Makefile``
      - ``TARGET = SK_MULTI_UART_SLOT_SQUARE``
      - ``TARGET = SK_MULTI_UART_SLOT_CIRCLE``

To build for TRIANGLE connector, make the following changes:

.. list-table::
    :header-rows: 1
    
    * - File
      - Original Value
      - New Value
    * - ``src/main.xc``
      - ``#define SK_MULTI_UART_SLOT_SQUARE 1``
      - ``#define SK_MULTI_UART_SLOT_TRIANGLE 1``
    * - ``Makefile``
      - ``TARGET = SK_MULTI_UART_SLOT_SQUARE``
      - ``TARGET = SK_MULTI_UART_SLOT_TRIANGLE``

To build for STAR connector, make the following changes:

.. list-table::
    :header-rows: 1
    
    * - File
      - Original Value
      - New Value
    * - ``src/main.xc``
      - ``#define SK_MULTI_UART_SLOT_SQUARE 1``
      - ``#define SK_MULTI_UART_SLOT_STAR 1``
    * - ``Makefile``
      - ``TARGET = SK_MULTI_UART_SLOT_SQUARE``
      - ``TARGET = SK_MULTI_UART_SLOT_STAR``

MultiUART component requires 8-bit ports for both UART transmit and UART receive ports. The version runs on L1 (one core) and also on L2 core, based on connector type selection. 

The UART slice has two types of voltage levels of communications.
    * CMOS TTL
    * RS-232
    
By default, this uses the RS-232 levels. In order to use the CMOS TTL levels, short J3 pins (25-26) of the MUART slice. At a time, only one voltage level type can be used for all 8 UART channels (RS-232 or CMOS TTL). When using the RS-232 levels, UART device pins must be connected to J4 of the UART slice. When using TTL levels, UART device pins must be connected to J3 of UART slice (along with J3 25-26 pins shorted). UART channel information of UART slice is as:

.. _table_connector_breakout:

MUART slice for Demo Applications 

================ ===================== =====================
**UART Channel** **J3/J4 Pin no.(TX)** **J3/J4 Pin no.(RX)**
================ ===================== =====================
0                1                     2
1                5                     6
2                7                     8 
3                11                    12
4                13                    14
5                17                    18
6                19                    20
7                23                    24
================ ===================== =====================


Demo Application Configuration
--------------------------------

The demo application configuration is done utilising the defines listed out below.

.. literalinclude:: app_slicekit_com_demo/src/common.h
    :start-after: //:demo_app_config
    :end-before:  //:
    
    
Application Description
------------------------

The demonstration application shows a typical structure of an application that might be implemented by the user of this component. 

In addition to the two multi-UART threads the application utilises one more thread to manage UART data from transmit and receive threads. Application operates on a state machine to differentiate between user commands and user data. Application provides some buffers to hold data received from UARTs. The RX buffering is implemented as an example only and is not strictly necessary in this application. TX thread already provides some buffering supported at the component level.

When the RX thread receives a character over the UART it saves it into the local buffer, and a state handler operates on the data to identify its type and performs relevant processign actions as described below:

[TBA]

Generally, the data token received by RX buffering thread tells which UART channel a character has been received on. The thread then grabs this character out of the buffer slot, validates it utilising the provided validation function and inserts it into a larger, more comprehensive buffer.

The TX handler operates by polling this buffer. When an entry is seen it pulls it from the buffer and perform action based on state of the handler. The TX handler will process that value on the correct UART channel on the 8 bit port.

The channel for the TX thread is primarily used for reconfiguration. This is discussed in more detail in :ref:`sec_reconf_rxtx`.

Specific usage of the API is discussed in :ref:`sec_interfacing_tx` and :ref:`sec_interfacing_rx`.

