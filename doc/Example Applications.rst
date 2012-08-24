Example Applications
====================

This section discusses the demonstration application that uses multi-uart module.

**app_slicekit_com_demo** Application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This application is available as ``app_slicekit_com_demo`` under ``sc_multi_uart`` component directory. See the evaluation platforms section of this document for required hardware.
    
.. _sec_demo_tools:

Required Software Tools
-----------------------

The following tools should be installed on the host system in order to run this application

    * For Win 7: Hercules Setup Utility by HW-Group
      http://www.hw-group.com/products/hercules/index_en.html
    * For MAC users: SecureCRT7.0 
      http://www.vandyke.com/download/securecrt/

.. _sec_slice_card_connection:

Build options
--------------

``app_slicekit_com_demo`` application use the following modules in order to achive its desired functionality.

    * **sc_multi_uart**: utilizes TX and RX servers provided by the component
    * **sc_util**: uses ``module_xc_ptr`` functions to perform pointer related arithmetic such as reading from and writing into memory


This demo application is built by default for XP-SKC-L2 Slicekit Core board, SQAURE connector type. This application can also be built for other compatible connectors as follows:

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

The module requires 8-bit ports for both UART transmit and UART receive ports.

Hardware Settings
-----------------

Voltage Levels
++++++++++++++

The XA-SK-UART8 Slice Card has two options for uart signalling levels:
    * CMOS TTL
    * RS-232
    
By default, this Slice Card uses the RS-232 levels. In order to use the CMOS TTL levels, short J3 pins (25-26) of the Slice Card. All 8 UART channels must use the same voltage setting. 

Uart Header Connections
+++++++++++++++++++++++

When using the RS-232 levels, UART device pins must be connected to J4 of XA-SK-UART8 Slice Card.

When using TTL levels, UART device pins must be connected to J3 of Multi-UART Slice Card (along with J3 25-26 pins shorted). UART information of XA-SK-UART8 Slice Card is as follows:

[ **ADD a picture of UART8 SliceCard in Square slot, with arrows added pointing to J3 and J4** ]

.. _table_connector_breakout:

XA-SK-UART8 Slice Card for Demo Applications 

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

Optionally, Uart #0 may be accessed via the DB9 connector on the end of the Slice Card and thus connected directly to a PC COM port.

Application Configuration
-------------------------

``app_slicekit_com_demo`` application configuration is done utilising the defines listed out below:

.. literalinclude:: app_slicekit_com_demo/src/common.h
    :start-after: //:demo_app_config
    :end-before:  //:
    
    
Application Description
-----------------------

The demonstration application shows a typical application structure that would employ the Multi-UART module. 

In addition to the two Multi-UART threads used by ``sc_multi_uart``, the application utilises one more thread to manage UART data from transmit and receive threads. 

UART data received may be user commands to perform various user actions or transaction data related to a user action (see :ref:`sec_demo_features`).

The application operates a state machine to differentiate between user commands and user data, and provides some buffers to hold data received from UARTs. When the RX thread receives a character over the UART it saves it into the local buffer. A state handler operates on the received data to identify its type and performs relevant actions .

Generally, the data token received by RX buffering thread tells which UART channel a character has been received on. The thread then extracts this character out of the buffer slot, validates it utilising the provided validation function and inserts it into a larger, more comprehensive buffer.The RX buffering is implemented as an example only and may not be necessary for other applications. The TX thread already provides some buffering supported at the component level. 

The TX handler operates by polling the buffer which is filled by the Rx handler. When an entry is seen, Tx handler pulls it from the buffer and perform an action based on current state of the handler.

The channel for the TX thread is primarily used for reconfiguration. This is discussed in more detail in :ref:`sec_reconf_rxtx`. Specific usage of the API is also discussed in :ref:`sec_interfacing_tx` and :ref:`sec_interfacing_rx`.


.. _sec_demo_usage:

Quick Start Guide
-----------------

.. _sec_demo_features:

Building and Running The Application
++++++++++++++++++++++++++++++++++++

The following components are required to build ``app_slicekit_com_demo`` application or develop sample Multi-UART applications:
    * sc_multi_uart: git://github.com/xcore/sc_multi_uart.git
    * sc_util: git://github.com/xcore/sc_util.git
    * xcommon: git://github.com/xcore/xcommon.git (Optional)

   #. Download the zipfile packages above.
   #. Open the XDE (XMOS Development Tools - latest version as of this writing is 11.11.1) and Choose `File` |submenu| `Import`.
   #. Choose `General` |submenu| `Existing Projects into Workspace` and click **Next**.
   #. Click **Browse** next to `Select archive file` and select the first firmware ZIP file.
   #. Repeat the import process for the remaining zipfiles. 
   #. Click **Finish**.
   #. To build, select `app_slicekit_com_demo` in the Project Explorer pane and click the **Build** icon.

Setting Up The Hardare
++++++++++++++++++++++

[add figure of HW Setup incl. debug adaptor, DB9 cable.]

   #. Connect XA-SK-UART8 Slice Card to the XA-SK-UART8 Slicekit Core board. This Slice Card can be connected to either ``Square``, ``Tringle`` or ``Star`` connector of Slicekit Core board as discussed in :ref:`sec_slice_card_connection`. For now, use the SQUARE slot as shown in the figure above:
   #. Connect COM port cable (provided with XA-SK-UART8 Slice Card package) to DB-9 connector on XA-SK-UART8 Slice Card. This enables UART 0 by default
   #. Connect other end of cable to Host (PC) DB-9 connector slot
   #. Identify COM port number provided by the Host and open a suitable terminal software for the selected COM port (see :ref:`sec_demo_tools`) for default parameters which are as follows: 115200 baud, 8 bit character length, even parity config, 1 stop bit and no hardware flow control  
   #. Connect the XTAG Adapter to Slicekit Core board, Chain connector and connect XTAG-2 to the adapter. 
   #. Connect the XTAG-2 can now be connected to your PC or Mac USB port.
   #. Switch on the power supply to the Slicekit Core board.
   #. Open the XDE
   #. Choose *File* |submenu| *Import* |submenu| *C/XC* |submenu| *C/XC Executable*
   #. Click **Browse** and select the new firmware (XE) file
   #. Click **Next** and **Finish**
   #. A Debug Configurations window is displayed. Click **Close**
   #. Choose *Run* |submenu| *Run Configurations*
   #. Double-click *Flash Programmer* to create a new configuration
   #. Browse for the XE file in the *Project* and *C/XC Application* boxes
   #. Ensure the *XTAG-2* device appears in the adapter list 
   #. Click **Run**
   #. Upon any key press on console, a user menu is displayed
   #. **Srini please describe in detail exactly what steps the user should take - exactly which comamnd below should be given and which example file should be uploaded - guide the user all the way through. After that they can be left toplay around by themselves**


Interacting with the Application
--------------------------------

Command Interface
+++++++++++++++++

The application provides the following commands to interact with it:

    * e - in this mode, an entered character is echoed back on the console. In order to come out of this mode, press the ``Esc`` key
    * r - reconfigure UART for a different baud rate
    * g - upload a file via console option; the uploaded file should be of size < 1024 characters and crc_appender application should be run on the file prior to file upload (see :ref:`sec_crc_appender_usage`)
    * p - this option prints previously uploaded file via get option on to the console; at the end, it displays timing consumed (in milliseconds) to upload a file and transmit back the same file to console
    * h - displays user menu
    
    At any instance ``Esc`` key can be pressed to revert back to user menu.


.. _sec_crc_appender_usage:

CRC Calculation Application
+++++++++++++++++++++++++++

To upload a file via the UART console, select any file with size < 1024 bytes. If the file size is greater than this size, only the first 1024 bytes are used. This limitation is due to buffer length constraints of the application, in order to store the received file and send it back when requested.

An application executable ``crc_appender`` which is available in ``test`` folder should be executed in order to calculate CRC of the selected file. This application appends calculated crc at the end of the file. ``app_slicekit_com_demo`` calculates CRC of the received bytes and checks it against the CRC value calculated by ``crc_appender`` application. This ensures all the user uploaded data is integrity checked.

Sample Usage:

   ::

       crc_appender <file_name>



Makefiles
---------

The main Makefile for the project is in the application directory. This file specifies build options and used modules. The Makefile uses the common build infrastructure in ``xcommon``. This system includes the source files from the relevant modules and is documented within ``xcommon``.


Using Command Line Tools
------------------------

To build from the command line, change to `app_slicekit_com_demo` directory and execute the command:

   ::

       xmake all

Open the XMOS command line tools (Desktop Tools Prompt) and execute the following command:

   ::

       xflash <binary>.xe


