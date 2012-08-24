module_multi_uart Com Port Demo: Quick Start Guide
--------------------------------------------------

``app_slicekit_com_demo`` is intended to showcase module_multi_uart key features and its API usage. 
This application supports UART reconfiguration for various standard baud rates, processes raw data and bulk upload (file based) data received, integrity checks on data and sends back the data.

Build the Application
++++++++++++++++++++++++

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

Set Up The Hardare
++++++++++++++++++

.. figure:: images/HardwareSetup.png
    :align: center

   #. Connect XA-SK-UART8 Slice Card to the XA-SK-UART8 Slicekit Core board. This Slice Card can be connected to either ``Square``, ``Tringle`` or ``Star`` connector of Slicekit Core board as discussed in :ref:`sec_slice_card_connection`. For now, use the SQUARE slot as shown in the figure above
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

Do the Demo
+++++++++++

   #. Upon any key press on console, a user menu is displayed
   #. Key in ``e``. Type in any character from the key board and application echoes back pressed keyed. In order to get back to user menu, press ``Esc`` key
   #. Key in ``r``. UART enters into reconfiguration mode and listens for new baud rate. Key in new baud rate value (select one of the values from 115200, 57600, 38400, 19200, 9600, 4800, 600) followed by CR (Enter) key. Upon successful reconfiguration, terminal console should be opened on the selected baud rate configuration. Press ``h`` to display user menu
   #. Key in ``g`` to upload a file from console. [**FIXME This CRC appender feature is yet to be added:** Before uploading a file, navigate to ``test`` directory and execute crc_appender application as *crc_appender <file_name>* This appends a CRC value calculated for the file contents]. Once a selected file is uploaded, press CTRL+D. Application now listens for any user commands. If any key other than ``p`` is pressed, all the uploaded file contents are lost **[FIXME Sample file, CRC application is yet to be tested and added into the repo]**
   #. Key in ``p`` in order to display the uploaded file contents on the console. **[FIXME CRC feature + error message to be added]**In case of any CRC mismatch, an error message is displayed. If this option is selected prior to using ``g`` option, an error message is displayed
   #. Key in ``h`` in order to display user menu. This help is displayed any time during execution by pressing ``Esc`` key followed by ``h`` 

Next Steps
++++++++++

   #. Refer to the module_multi_uart documentation for implementation details of this application and information on further things to try.
   #. Evaluate the full Ethernet to Serial (8 Uart) reference product which can be found at https://github.com/xcore/sw_serial_to_ethernet. This is a fully featured reference product including an embedded webserver, multicast configuration via UDP and a host of other features. 
