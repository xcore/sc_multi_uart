Example Applications
=====================

This section discusses the demonstration application that uses Multi-UART component.

Demonstration Application
~~~~~~~~~~~~~~~~~~~~~~~~~

This application is available as ``app_slicekit_com_demo`` under ``sc_multi_uart`` component directory.

Demo Application Hardware
-------------------------

app_slicekit_com_demo application can be demonstrated on Slicekit Core board. The following parts are required

    * Slicekit Core board
    * MUART Slice Card
    * RS232 to COM port cable (provided with MUART Slice Card package)
    
.. _sec_demo_tools:

Required Software Tools
-----------------------

Following tools may be installed on the host system in order to use the demo application

    * For Win 7: Hercules Setup Utility by HW-Group
      http://www.hw-group.com/products/hercules/index_en.html
    * For MAC users: SecureCRT7.0 
      http://www.vandyke.com/download/securecrt/

.. _sec_slice_card_connection:

Slice Card Build options
------------------------

This demo application is built by default for Slicekit Core board, SQAURE connector type. This application can also be built for other compatible connectors as follows:

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

Multi-UART component requires 8-bit ports for both UART transmit and UART receive ports.

Multi-UART Slice Card has two types of voltage levels of communications.
    * CMOS TTL
    * RS-232
    
By default, this Slice Card uses the RS-232 levels. In order to use the CMOS TTL levels, short J3 pins (25-26) of the Slice Card. At a time, only one voltage level type can be used for all 8 UART channels (RS-232 or CMOS TTL). When using the RS-232 levels, UART device pins must be connected to J4 of Multi-UART Slice Card. When using TTL levels, UART device pins must be connected to J3 of Multi-UART Slice Card (along with J3 25-26 pins shorted). UART information of Multi-UART Slice Card is as follows:

.. _table_connector_breakout:

MUART Slice Card for Demo Applications 

=================== ===================== =====================
**UART Identifier** **J3/J4 Pin no.(TX)** **J3/J4 Pin no.(RX)**
=================== ===================== =====================
0                   1                     2
1                   5                     6
2                   7                     8 
3                   11                    12
4                   13                    14
5                   17                    18
6                   19                    20
7                   23                    24
=================== ===================== =====================

Components Dependency
---------------------

``app_slicekit_com_demo`` application uses the following components in order to achive its desired functionality.

    * **sc_multi_uart**: utilizes TX and RX servers provided by the component
    * **sc_util**: uses ``module_xc_ptr`` functions to perform pointer related arithmetic such as reading from and writing into memory


Application Configuration
-------------------------

The demo application configuration is done utilising the defines listed out below.

.. literalinclude:: app_slicekit_com_demo/src/common.h
    :start-after: //:demo_app_config
    :end-before:  //:
    
    
Application Description
-----------------------

The demonstration application shows a typical structure of an application that might be implemented by the user of ``sc_multi_uart`` component. 

In addition to the two Multi-UART threads used by ``sc_multi_uart`` component, application utilises one more thread to manage UART data from transmit and receive threads. 

UART data received can be typically user commands to perform various user actions and UART transaction data (see :ref:`sec_demo_features`).

Application operates on a state machine to differentiate between user commands and user data. Application provides some buffers to hold data received from UARTs. When the RX thread receives a character over the UART it saves it into the local buffer. A state handler operates on the received data to identify its type and performs relevant actions .

Generally, the data token received by RX buffering thread tells which UART channel a character has been received on. The thread then grabs this character out of the buffer slot, validates it utilising the provided validation function and inserts it into a larger, more comprehensive buffer.The RX buffering is implemented as an example only and is not strictly necessary in this application. TX thread already provides some buffering supported at the component level. 

TX handler operates by polling the buffer which is filled by Rx handler. When an entry is seen, Tx handler pulls it from the buffer and perform action based on current state of the handler.

The channel for the TX thread is primarily used for reconfiguration. This is discussed in more detail in :ref:`sec_reconf_rxtx`. Specific usage of the API is also discussed in :ref:`sec_interfacing_tx` and :ref:`sec_interfacing_rx`.


.. _sec_demo_usage:

Getting Started
---------------

#. Connect MUART Slice Card to the Slicekit Core board. MUART slice can be connected to either ``Circle`` or ``Star`` connector of Slicekit Core board as discussed in :ref:`sec_slice_card_connection`

#. Connect COM port cable (provided with MUART Slice Card package) to DB-9 connector on MUART Slice Card. This enables UART 0 by default

#. Connect other end of cable to Host (PC) DB-9 connector slot

#. Identify COM port number provided by the Host and open a suitable terminal software for the selected COM port (see :ref:`sec_demo_tools`) for default parameters which are as follows: 115200 baud, 8 bit character length, Even parity config, 1 stop bit and No hardware flow control  

#. Switch on the power supply to the Slicekit Core board

#. Upon any key press on console, a user menu is displayed

#. From there, demo is guided by the selection of respective options, which are described in more detail in :ref:`sec_demo_features`


.. _sec_demo_features:

User Options
------------

User selects one of the following characters in order to use the relevant demo application feature

    * e - in this mode, user entered character is echoed back on the console. In order to come out of this mode, user should press ``Esc`` key
    * r - this option can be selected in order to reconfigure UART for a different baud rate
    * g - upload a file via console option; uploaded file should be of size < 1024 characters and crc_appender application should be run prior to file upload (see :ref:`sec_crc_appender_usage`)
    * p - this option prints previously uploaded file via get option, on to the console; at the end, it displays timing consumed (in milli sec) to upload a file and transmit back the same file to console
    * h - displays user menu
    
    At any instance ``Esc`` key can be pressed to revert back to user menu.


.. _sec_crc_appender_usage:

CRC Calculation Application
---------------------------

For uploading a file via UART console, user can select any file whose size is < 1024 bytes. 
An application executable ``crc_appender`` which is available in ``test`` folder should be executed in order to calculate CRC of the selected file. This application appends calculated crc at the end of the file. demonstartion application calculates CRC of the received bytes and checks it against the CRC value calculated by the application. This ensures all the user uploaded data is integrity checked by the application.

Sample Usage:

  crc_appender <file_name>
