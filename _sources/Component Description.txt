Component Description
=====================

Multi-UART component consists of Transmit and receive servers. An application utilizing this component can use them independently or togeather based on the application needs.

Threads
-------

The multi-UART component comprises primarily of two threads that act as transmit (TX) and receive (RX) servers.

Buffering
---------

Buffering for the TX server is handled within the UART TX thread. The buffer is configurable allowing the number of buffer slots that are available to be defined. This is only limited by the available memory left by the rest of the code and data memory usage. Data is transferred to the UART TX thread via shared memory and therefore any client thread must be on the same core as the UART thread.

There is no buffering provided by the RX server. The application must provide a thread that is able to respond to received characters in real time and handle any buffering requirements for the application that is being developed.

Communication Model
-------------------

This component utilises a combination of shared memory and channel communication. Channel communication is used on both the RX and TX servers to pause the thread and subsequently release the thread when required for reconfiguration.

The primary means of data transfer for both the RX and TX threads is shared memory. The RX thread utilises a channel to notify any client of available data - this means that events can be utilised within an application to avoid the requirement for polling for received data.


.. _sec_ext_clk:

Clocking
--------

The component can be configured to either use an external clock source or an internal clock source. External clock source only applies to the TX portion of the component (see :ref:`sec_tx_conf_header`). The advantage of using an external clock source is that an exact baud rate can be achieved by dividing down a master clock such as 1.8432MHz. This is a typical method that standard RS232 devices will use.

Using internal clocking is possible, but for TX the implementation currently limits the application to configuring baud rates that divide exactly into the internal clock. So if the system reference runs at 100MHz the maximum baud rate is 100kbaud.

The RX implementation uses the internal clock under all circumstances. Clock drift is handled by the implementation utilising oversampling to ensure that the bit is sampled as close to the centre of the bit time as possible. This minimises error due to the small drift that is encountered. The syncronisation of the sampling is also reset on every start bit so drift is minimised in a stream of data.

It should be noted that if extremely long data lengths are used the drift encountered may become large as the fractional error will accumulate over the length of the UART word. By taking the fractional error (say for an internal clock of 100MHz and a baud rate of 115200bps we have a fractional error of 0.055) and multiplying it by the number of bits in a UART word (for 8 data bits, 1 parity and one stop bit we have a word length of 11 bits). Thus for the described configuration a drift of 0.61 clock ticks is encountered. This equates to 0.07%.
