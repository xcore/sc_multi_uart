module_multi_uart Com Port Demo: Quick Start Guide
--------------------------------------------------

**srini, enter a quick overview of what the demo entails here**

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

Do the Demo
+++++++++++

   #. Upon any key press on console, a user menu is displayed
   #. **Srini please describe in detail exactly what steps the user should take - exactly which comamnd below should be given and which example file should be uploaded - guide the user all the way through. After that they can be left toplay around by themselves**

Next Steps
++++++++++

   #. Refer to the module_multi_uart documentation for implementation details of this application and information on further things to try.
   #. Evaluate the full Ethernet to Serial (8 Uart) reference product which can be found at https://github.com/xcore/sw_serial_to_ethernet. This is a fully featured reference product including an embedded webserver, multicast configuration via UDP and a host of other features. 
