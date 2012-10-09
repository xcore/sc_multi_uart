// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: main.xc
 Project : app_sk_muart_com_demo
 Author  : XMOS Ltd
 Version : 1v0
  -----------------------------------------------------------------------------*/

#include <xs1.h>
#include <platform.h>
#include <print.h>
#include <string.h>
#include "multi_uart_common.h"
#include "multi_uart_rxtx.h"
#include "uart_manager.h"
#include "common.h"

#define SK_MULTI_UART_SLOT_SQUARE 1

#ifdef SK_MULTI_UART_SLOT_SQUARE
#define UART_CORE   1
on stdcore[UART_CORE]:s_multi_uart_tx_ports uart_tx_ports = { XS1_PORT_8B };
on stdcore[UART_CORE]:s_multi_uart_rx_ports uart_rx_ports = { XS1_PORT_8A };
on stdcore[UART_CORE]: in port p_uart_ref_ext_clk = XS1_PORT_1F; /* Define 1 bit external clock */

#elif SK_MULTI_UART_SLOT_STAR
#define UART_CORE   0
on stdcore[UART_CORE]:s_multi_uart_tx_ports uart_tx_ports = { XS1_PORT_8B };
on stdcore[UART_CORE]:s_multi_uart_rx_ports uart_rx_ports = { XS1_PORT_8A };
on stdcore[UART_CORE]: in port p_uart_ref_ext_clk = XS1_PORT_1F; /* Define 1 bit external clock */

#elif SK_MULTI_UART_SLOT_TRIANGLE
#define UART_CORE   0
on stdcore[UART_CORE]:s_multi_uart_tx_ports uart_tx_ports = { XS1_PORT_8D };
on stdcore[UART_CORE]:s_multi_uart_rx_ports uart_rx_ports = { XS1_PORT_8C };
on stdcore[UART_CORE]: in port p_uart_ref_ext_clk = XS1_PORT_1L; /* Define 1 bit external clock */
#endif


on stdcore[UART_CORE]: clock clk_uart_tx = XS1_CLKBLK_4;
on stdcore[UART_CORE]: clock clk_uart_rx = XS1_CLKBLK_5;

/* Dummy Thread*/
void dummy()
{
	while(1)
	{

	}
}

/**
 * Top level main for multi-UART demonstration
 */
int main(void)
{
    streaming chan c_tx_uart;
    streaming chan c_rx_uart;

    par
    {
        on stdcore[UART_CORE]: uart_manager(c_tx_uart, c_rx_uart);
        on stdcore[UART_CORE]: run_multi_uart_rxtx( c_tx_uart,  uart_tx_ports, c_rx_uart, uart_rx_ports, clk_uart_rx, p_uart_ref_ext_clk, clk_uart_tx);

        /* dummy threads*/
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
    }

    return 0;
}
