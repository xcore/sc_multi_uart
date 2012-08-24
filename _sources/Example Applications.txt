Example Applications
=====================

This section discusses the demonstration application that uses Multi-UART component.

**app_slicekit_com_demo** Application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This application is available as ``app_slicekit_com_demo`` under ``sc_multi_uart`` component directory.

Recommended Hardware
---------------------

``app_slicekit_com_demo`` application can be evaluated on Slicekit Core board. The following parts are required

    * XP-SKC-L2 (Slicekit L2 Core Board)
    * XA-SK-UART8 Slice Card
    * RS232 to COM port cable (provided with XA-SK-UART8 Slice Card package)
    
.. _sec_demo_tools:

Required Software Tools
-----------------------

Following tools may be installed on the host system in order to use the demo application

    * For Win 7: Hercules Setup Utility by HW-Group
      http://www.hw-group.com/products/hercules/index_en.html
    * For MAC users: SecureCRT7.0 
      http://www.vandyke.com/download/securecrt/

.. _sec_slice_card_connection:

Build options
--------------

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

Multi-UART component requires 8-bit ports for both UART transmit and UART receive ports.

XA-SK-UART8 Slice Card has two types of voltage levels of communications.
    * CMOS TTL
    * RS-232
    
By default, this Slice Card uses the RS-232 levels. In order to use the CMOS TTL levels, short J3 pins (25-26) of the Slice Card. At a time, only one voltage level type can be used for all 8 UART channels (RS-232 or CMOS TTL). When using the RS-232 levels, UART device pins must be connected to J4 of XA-SK-UART8 Slice Card. When using TTL levels, UART device pins must be connected to J3 of Multi-UART Slice Card (along with J3 25-26 pins shorted). UART information of XA-SK-UART8 Slice Card is as follows:

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


``app_slicekit_com_demo`` application use the following components in order to achive its desired functionality.

    * **sc_multi_uart**: utilizes TX and RX servers provided by the component
    * **sc_util**: uses ``module_xc_ptr`` functions to perform pointer related arithmetic such as reading from and writing into memory


Application Configuration
-------------------------

``app_slicekit_com_demo`` application configuration is done utilising the defines listed out below:

.. literalinclude:: app_slicekit_com_demo/src/common.h
    :start-after: //:demo_app_config
    :end-before:  //:
    
    
Application Description
-----------------------

The demonstration application shows a typical structure of an application that might be implemented by the user of ``sc_multi_uart`` component. 

In addition to the two Multi-UART threads used by ``sc_multi_uart`` component, application utilises one more thread to manage UART data from transmit and receive threads. 

UART data received can be typically user commands to perform various user actions or UART data received can be transaction data related to a user action (see :ref:`sec_demo_features`).

Application operates on a state machine to differentiate between user commands and user data. Application provides some buffers to hold data received from UARTs. When the RX thread receives a character over the UART it saves it into the local buffer. A state handler operates on the received data to identify its type and performs relevant actions .

Generally, the data token received by RX buffering thread tells which UART channel a character has been received on. The thread then grabs this character out of the buffer slot, validates it utilising the provided validation function and inserts it into a larger, more comprehensive buffer.The RX buffering is implemented as an example only and may not be necessary for other applications. TX thread already provides some buffering supported at the component level. 

TX handler operates by polling the buffer which is filled by Rx handler. When an entry is seen, Tx handler pulls it from the buffer and perform an action based on current state of the handler.

The channel for TX thread is primarily used for reconfiguration. This is discussed in more detail in :ref:`sec_reconf_rxtx`. Specific usage of the API is also discussed in :ref:`sec_interfacing_tx` and :ref:`sec_interfacing_rx`.


.. _sec_demo_usage:

Getting Started
+++++++++++++++

This section describes how to use the demo application with Slicekit hardware.

#. Connect XA-SK-UART8 Slice Card to the XA-SK-UART8 Slicekit Core board. This Slice Card can be connected to either ``Square``, ``Tringle`` or ``Star`` connector of Slicekit Core board as discussed in :ref:`sec_slice_card_connection`

#. Connect COM port cable (provided with XA-SK-UART8 Slice Card package) to DB-9 connector on XA-SK-UART8 Slice Card. This enables UART 0 by default

#. Connect other end of cable to Host (PC) DB-9 connector slot

#. Identify COM port number provided by the Host and open a suitable terminal software for the selected COM port (see :ref:`sec_demo_tools`) for default parameters which are as follows: 115200 baud, 8 bit character length, even parity config, 1 stop bit and no hardware flow control  

#. Switch on the power supply to the Slicekit Core board

#. Upon any key press on console, a user menu is displayed

#. From there, demo is guided by the selection of respective options, which are described in more detail in :ref:`sec_demo_features`


.. _sec_demo_features:

Usage Options
+++++++++++++

User selects one of the following characters in order to use the relevant demo application feature

    * e - in this mode, user entered character is echoed back on the console. In order to come out of this mode, user should press ``Esc`` key
    * r - this option can be selected in order to reconfigure UART for a different baud rate
    * g - upload a file via console option; uploaded file should be of size < 1024 characters and crc_appender application should be run prior to file upload (see :ref:`sec_crc_appender_usage`)
    * p - this option prints previously uploaded file via get option on to the console; at the end, it displays timing consumed (in milli sec) to upload a file and transmit back the same file to console
    * h - displays user menu
    
    At any instance ``Esc`` key can be pressed to revert back to user menu.


.. _sec_crc_appender_usage:

CRC Calculation Application
---------------------------

For uploading a file via UART console, user can select any file with size is < 1024 bytes. If the file size is greater than this size, only the first 1024 bytes are used. This limitation is primarily due to buffer length constraints of the application, in order to store the received file and send it back when requested.

An application executable ``crc_appender`` which is available in ``test`` folder should be executed in order to calculate CRC of the selected file. This application appends calculated crc at the end of the file. ``app_slicekit_com_demo`` calculates CRC of the received bytes and checks it against the CRC value calculated by ``crc_appender`` application. This ensures all the user uploaded data is integrity checked.

Sample Usage:

   ::

       crc_appender <file_name>


Building Procedure
~~~~~~~~~~~~~~~~~~

Following section describes the procedure in order to build the software.

Installation
------------

The following components are required to build ``app_slicekit_com_demo`` application or develop sample Multi-UART applications:
    * sc_multi_uart: git://github.com/xcore/sc_multi_uart.git
    * sc_util: git://github.com/xcore/sc_util.git
    * xcommon: git://github.com/xcore/xcommon.git (Optional)

Once the zipfiles are downloaded you can install, build and use the software.

Building with the XDE
---------------------

To install the software, open the XDE (XMOS Development Tools - latest version as of this writing is 11.11.1) and follow these steps:

#. Choose `File` |submenu| `Import`.

#. Choose `General` |submenu| `Existing Projects into Workspace` and click **Next**.

#. Click **Browse** next to `Select archive file` and select the file firmware ZIP file.

#. Make sure the projects you want to import are ticked in the `Projects` list. Import all the components and whichever applications you are interested in.

#. Click **Finish**.

To build, select `app_slicekit_com_demo` in Project Explorer pane and click the **Build** icon.

Building from the command line
------------------------------

To build from the command line, change to `app_slicekit_com_demo` directory and execute the command:

   ::

       xmake all

Makefiles
---------

The main Makefile for the project is in the application directory. This file specifies build options and used modules. The Makefile uses the common build infrastructure in ``xcommon``. This system includes the source files from the relevant modules and is documented within ``xcommon``.

Installing the application onto flash 
-------------------------------------

Using XDE
+++++++++

To upgrade (or flash) the firmware you must, firstly:

#. Connect the XTAG Adapter to Slicekit Core board, Chain connector and connect XTAG-2 to the adapter. This XTAG-2 can now be connected to your PC or Mac.

#. Switch on the power supply to Slicekit Core board

#. Start the XMOS Development Environment and open a workspace

#. Choose *File* |submenu| *Import* |submenu| *C/XC* |submenu| *C/XC Executable*

#. Click **Browse** and select the new firmware (XE) file

#. Click **Next** and **Finish**

#. A Debug Configurations window is displayed. Click **Close**

#. Choose *Run* |submenu| *Run Configurations*

#. Double-click *Flash Programmer* to create a new configuration

#. Browse for the XE file in the *Project* and *C/XC Application* boxes

#. Ensure the *XTAG-2* device appears in the adapter list

#. Click **Run**


Using Command Line Tools
++++++++++++++++++++++++

#. Open the XMOS command line tools (Desktop Tools Prompt) and execute the following command:

   ::

       xflash <binary>.xe
