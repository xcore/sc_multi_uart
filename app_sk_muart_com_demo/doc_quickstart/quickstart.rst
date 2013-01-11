Multiuart Com Demo: Quick Start Guide
--------------------------------------------------

This demonstration uses the XA-SK-UART-8 Multi UART Slice Card together with the xSOFTip Multi-UART component to create 8 UARTs. The working is shown as follows

   * Data is received from a host computer over a null modem cable on the first uart (Uart 0) using the DB9 connector.
   * Received data is piped through the remaining 7 uarts using loopback connections on the Slice Card. 
   * After data has passed through all uarts 1 through 7, the data is then returned back to the host computer via Uart 0 and the DB9 connector.

This demo also features UART reconfiguration for a sample of standard baud rates.

Host Computer Setup
+++++++++++++++++++

The following tools should be installed on the host system in order to run this application:
 
    * For Win 7: `Hercules Setup Utility by HW-Group <http://www.hw-group.com/products/hercules/index_en.html>`_
    * For MAC users: `SecureCRT7.0 <http://www.vandyke.com/download/securecrt/>`_

Similar tools exist for Linux users but for the purposes of this demonstartion a Windows or OS X platform using the tools above is recommended.

Hardware Setup
++++++++++++++

The following hardware components are required:

* XP-SKC-L2 (Slicekit L2 Core Board)
* XA-SK-UART-8 (Audio board)
* XA-SK-XTAG2 (Slicekit XTAG adaptor)
* XTAG-2 (XTAG Connector board)

XP-SKC-L2 Slicekit Core board has four slots with edge conectors: ``SQUARE``, ``CIRCLE``, ``TRIANGLE`` and ``STAR``, 
and one chain connector marked with a ``CROSS``.

To setup up the system refer to the figure and instructions below.

Set Up The Multi Uart Slice Card
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: images/pipe_hardware.png
   :align: center

   Setting up the Loopback Jumpers

The demo shows the transfer of characters accross all 8 uarts by looping them all back. Data will be received (RX) from the host computer on Uart 0 (pins 0 and 1 of the header on the Slice Card), transmitted through the remaining 7 uarts and then the result of that is sent back to the host via Uart 0 TX.

You will need seven 2-pin jumpers, which should be placed on header J4 (the one nearest the DB9 connector and labelled "RS-232") of the Slice Card, on all the rows numbered 1 through 7 on the Slice Card. The table below denotes the header pin connections made by the jumpers placed in the figure.

.. list-table::
    :header-rows: 1 
    
    * - TX
      - RX
    * - 5 
      - 6 
    * - 7 
      - 8
    * - 11 
      - 12
    * - 13
      - 14
    * - 17
      - 18
    * - 19
      - 20
    * - 23
      - 24

Setting Up The System
~~~~~~~~~~~~~~~~~~~~~

   #. Connect the XA-SK-MUART Slice Card to the XP-SKC-L2 Slicekit Core board using the connector marked with ``SQUARE``.
   #. Connect the XTAG Adapter to Slicekit Core board, and connect XTAG-2 to the adapter. Turn the XLINK switch on the debug adapater to the "ON" position.
   #. Connect a null serial cable to DB-9 connector on XA-SK-MUART Slice Card. The cable will need a cross over between the UART RX and TX pins at each end.
   #. Connect the other end of cable to the host computer DB-9 connector slot. If the Host does not have an DB-9 Connector slot then use USB-UART cable for the demo. We used the BF-810 USB to Uart adapter (See http://www.bafo.com/products_bf-810_S.asp (Part number : BF-810). Any other usb to uart bridge should do just as well.
   #. Identify the serial (COM) port number provided by the Host or the USB to UART adapter and open a suitable terminal software for the selected serial port (refer to the Hercules or SecureCRT documentation above).
   #. Configure the host terminal console program as follows: 115200 baud, 8 bit character length, even parity, 1 stop bit, no hardware flow control. The Transmit End-of-Line character should be set to ``CR`` (other options presented will probably be ``LF`` and ``CR\LF``).
   #. Connect the XTAG Adapter to Slicekit Core board, XA-SK-XTAG2 connector(xtag slice) and connect XTAG-2 to the adapter. Switch on the power supply to the Slicekit Core board.
   #. Open the serial device on the host console program
   
.. figure:: images/hardware_setup.png
   :align: center

   Full system setup for Multi-UART Demo

Import and Build the Application
++++++++++++++++++++++++++++++++

   #. Open xTimeComposer then open the edit perspective (Window->Open Perspective->XMOS Edit).
   #. Locate the ``Slicekit COM Port MUART Demo`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTimeComposer. This will cause the modules on which this application depends (in this case, sc_util) to be imported as well. 
   #. Click on the Slicekit COM Port MUART Demo item in the Explorer pane then click on the build icon (hammer) in xTimeComposer. Check the console window to verify that the application has built successfully.

For help in using xTimeComposer, try the xTimeComposer tutorial (see ``Help->Tutorials`` within the tool).

Note that the Developer Column in the xTimeComposer on the right hand side of your screen provides information on the xSOFTip components you are using, when the component is selected in the xSOFTip browser pane. 

Run the Application
+++++++++++++++++++

   #. Open the configured terminal client application console on the host computer
   #. Click on the ``Run`` icon (the white arrow in the green circle) and wait for the application running message in XDE console for all UARTs before proceeding to the next step.
   #. A user menu will be displayed on terminal client application console 
   #. Key in ``e`` to enter echo mode. Type in any character from thekey board and application echoes the key pressed. In order to get back to user menu, press ``Esc`` key.
   #. Key in ``r`` to enter reconfiguration mode. Select a new baud rate value (choose 1 for 115200 baud, 2 for 57600 baud, 3 for 9600 baud and 4 for 600 baud selection). The UART will be reconfigured (XDE console will display the reconfigured value). The terminal console should be reopened with the new selected baud rate. Press ``h`` to display user menu.
   #. Key in ``f`` in order to transfer a file through UART 0. Use file upload option if it is supported by terminal client application or type in the Console window and then press Ctrl+D to send the data and recieve it for display. In order to get back to user menu, press ``Esc`` key.
   #. Key in ``b`` in order to pipe data through UART channels 1-7. Type in the Console window and then press Ctrl+D to send the data through 7 channels and recieve it for display. Hardware setup for Pipe option should be as shown in the Loopback Connections Figure above. If the connection to any of the channels is disconnected you will not see data received back and a message is displayed on the terminal console saying that the Muart pipe is broken.
   #. If you successfully sent characters using the ``b`` option above, verify that the MUART pipe through all uarts is indeed present by removing one of the jumpers, repreating the ``b``, ``CTRL-D`` sequence above upon which an error message regarding the broken pipe should be displayed.
   #. Key in ``h`` in order to display user menu. This help is displayed any time during execution by pressing ``Esc`` key followed by ``h``

.. figure:: images/help_menu.png
   :align: center

   Screenshot of Hyperterminal window

      
Next Steps
++++++++++

   #. Refer to the module_multi_uart documentation for implementation details of this application and information on further things to try.
   #. Evaluate the full Ethernet to Serial (8 Uart) reference product. This is a fully featured reference product including an embedded webserver, multicast configuration via UDP and a host of other features. and can be accessed by applying to your XMOS sales representative.
   #. Examine the application code. In xTimeComposer navigate to the ``src`` directory under app_sk_muart_com_demo and double click on the main.xc file within it. The file will open in the central editor window.
   #. This code employs three logical cores. The par{} statement at the bottom of ``main.xc`` instances the Multi-Uart by calling it's server function, ``run_multi_uart_rxtx()``. This is a function which does not return and runs the Multi-Uart and uses two logical cores (one for 8 Uart TX, and another for 8 uart RX) . It also instances a logical core running ``uart_manager()``. This uart_manager is the demo application code which displays the help menu, effects the 8 channel loopback and so on. 
   #. Since only one call is made to ``run_multi_uart_rxtx()`` in the ``par{}`` in ``main.xc``, why does it say above that two logical cores actually used by this component? To see why, navigate to the ``module_multi_uart`` in the Project Explorer pane, double-lick to open its contents and then navigate to the ``src`` directory and open ``multi_uart_rxtx.xc`` in the editor by double clicking it. Now it is possible to see the two logical cores used by the Multi-Uart - there is another ``par{}`` statement which calls the ``run_multi_uart_tx`` and ``run_multi_uart_rx`` server functions causing them to be executed on separate logical cores.

