#include <xs1.h>
#include <platform.h>
#include "multi_uart_rxtx.h"
#include "uart_manager.h"

on tile[1]: s_multi_uart_tx_ports uart_tx_ports = { XS1_PORT_8B };
on tile[1]: s_multi_uart_rx_ports uart_rx_ports = { XS1_PORT_8A };
/* Define 1 bit external clock */
on tile[1]: in port p_uart_ref_ext_clk = XS1_PORT_1F;

on tile[1]: clock clk_uart_tx = XS1_CLKBLK_4;
on tile[1]: clock clk_uart_rx = XS1_CLKBLK_5;

/**
 * Top level main for multi-UART demonstration
 */
int main(void)
{
    streaming chan c_tx_uart;
    streaming chan c_rx_uart;

    par
    {
        on tile[1]: uart_app_manager(c_tx_uart, c_rx_uart);
        on tile[1]: run_multi_uart_rxtx( c_tx_uart,  uart_tx_ports, c_rx_uart, uart_rx_ports, clk_uart_rx, p_uart_ref_ext_clk, clk_uart_tx);
    }
    return 0;
}
