.. _sec_common_api:

Multi UART Common API 
=====================

The following describes the shared API between the UART RX Server and UART TX Server code.

.. _sec_common_enum:

Enum Definitions
-----------------

.. doxygenenum:: ENUM_UART_CONFIG_PARITY

.. doxygenenum:: ENUM_UART_CONFIG_STOP_BITS

.. doxygenenum:: ENUM_UART_CONFIG_POLARITY

.. _sec_common_func:

Combined RX & TX server launch functions
-----------------------------------------

.. doxygenfunction:: run_multi_uart_rxtx_int_clk

.. doxygenfunction:: run_multi_uart_rxtx

.. _sec_tx_api:

Multi UART transmit API 
=======================

The following describes the public API for use in applications and the API's usage.

.. _sec_tx_conf_defines:

Configuration defines
----------------------

The file ``multi_uart_tx_conf.h`` must be provided in the application source code. This file should comprise of the following defines:

**UART_TX_USE_EXTERNAL_CLOCK**

    Define whether to use an external clock reference for transmit - do not define this if using the internal clocking

**UART_TX_CHAN_COUNT**

    Define the number of channels that are to be supported, must fit in the port. Also, must be a power of 2 (i.e. 1,2,4,8) - not all channels have to be utilised
    
**UART_TX_CLOCK_RATE_HZ**

    This defines the master clock rate - if using an external clock then set this appropriately (e.g. 1843200 for a 1.8432MHz external clock)
    
**UART_TX_MAX_BAUD**

    Define the maximum application baud rate - this implementation is validated to 115200 baud
    
**UART_TX_CLOCK_DIVIDER**

    This should be defined as ``(UART_TX_CLOCK_RATE_HZ/UART_TX_MAX_BAUD_RATE)``. But some use cases may require a custom divide.
    
**UART_TX_OVERSAMPLE**

    Define the oversampling of the clock - this is where the UART_TX_CLOCK_DIVIDER is > 255 (otherwise set to 1) - only used when using an internal clock reference
    
**UART_TX_BUF_SIZE**

    Define the buffer size in UART word entries - needs to be a power of 2 (i.e. 1,2,4,8,16,32)
    
**UART_TX_IFB**

    Define the number of interframe bits

.. _sec_tx_data_struct:

Data structures
---------------

.. doxygenstruct:: STRUCT_MULTI_UART_TX_PORTS

.. doxygenstruct:: STRUCT_MULTI_UART_TX_CHANNEL

.. _sec_tx_conf_func:

Configuration functions
-----------------------

.. doxygenfunction:: uart_tx_initialise_channel

.. doxygenfunction:: uart_tx_reconf_pause

.. doxygenfunction:: uart_tx_reconf_enable

.. _sec_tx_func:

Transmission functions
----------------------

.. doxygenfunction:: uart_tx_assemble_word

.. doxygenfunction:: uart_tx_put_char

.. _sec_tx_server_func:

Multi UART TX server
--------------------

.. doxygenfunction:: run_multi_uart_tx

.. _sec_rx_api:

Multi UART receive API 
=======================

The following describes the public API for use in applications and the API's usage.

.. _sec_rx_conf_defines:

Configuration defines
---------------------

The file ``multi_uart_rx_conf.h`` must be provided in the application source code. This file should comprise of the following defines:

**UART_RX_CHAN_COUNT**

    Define the number of channels that are to be supported, must fit in the port. Also, must be a power of 2 (i.e. 1,2,4,8) - not all channels have to be utilised
    
**UART_RX_CLOCK_RATE_HZ**

    This defines the master clock rate - in this implementation this is the system clock in Hertz. This should be 100000000.
    
**UART_RX_MAX_BAUD**

    Define the maximum application baud rate - this implementation is validated to 115200 baud
    
**UART_RX_CLOCK_DIVIDER**

    This should be defined as ``(UART_RX_CLOCK_RATE_HZ/UART_RX_MAX_BAUD)``. But some use cases may require a custom divide.
    
**UART_RX_OVERSAMPLE**

    Define receive oversample for maximum baud rate. This should be left at 4.

.. _sec_rx_data_struct:

Data structures
---------------

.. doxygenstruct:: STRUCT_MULTI_UART_RX_PORTS

.. doxygenstruct:: STRUCT_MULTI_UART_RX_CHANNEL

.. _sec_rx_conf_func:

Configuration functions
-----------------------

.. doxygenfunction:: uart_rx_initialise_channel

.. doxygenfunction:: uart_rx_reconf_pause

.. doxygenfunction:: uart_rx_reconf_enable

.. _sec_rx_data_validation_func:

Data validation functions
-------------------------

.. doxygenfunction:: uart_rx_validate_char

Data fetch functions
--------------------

.. doxygenfunction:: uart_rx_grab_char

.. _sec_rx_server_func:

Multi UART RX server
--------------------

.. doxygenfunction:: run_multi_uart_rx

.. _sec_helper_api:

Multi UART helper API
=====================

This API provides a number of functions that allow the access of architecture specific functionality within C where XC semantics are not available.

.. doxygenfunction:: get_time

.. doxygenfunction:: wait_for

.. doxygenfunction:: wait_until

.. doxygenfunction:: send_streaming_int

.. doxygenfunction:: get_streaming_uint

.. doxygenfunction:: get_streaming_token
