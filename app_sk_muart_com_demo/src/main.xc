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
#elif SK_MULTI_UART_SLOT_STAR
#define UART_CORE   0
#elif SK_MULTI_UART_SLOT_TRIANGLE
#define UART_CORE   0
#endif

s_multi_uart_tx_ports uart_tx_ports = { PORT_UART_TX };
s_multi_uart_rx_ports uart_rx_ports = {	PORT_UART_RX };

on stdcore[UART_CORE]: clock clk_uart_tx = XS1_CLKBLK_4;
on stdcore[UART_CORE]: in port p_uart_ref_ext_clk = PORT_UART_EXT_CLK; /* Define 1 bit external clock */
on stdcore[UART_CORE]: clock clk_uart_rx = XS1_CLKBLK_5;

void dummy()
{
    while (1);
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

        /* use all 8 threads */
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
        on stdcore[UART_CORE]: dummy();
    }

    return 0;
}
