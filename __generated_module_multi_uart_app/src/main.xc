#include <platform.h>
#include <xs1.h>
#include "multi_uart_common.h"
#include "multi_uart_rxtx.h"
#include "multi_uart_tx.h"
#include "multi_uart_rx.h"

    s_multi_uart_tx_ports uart_tx_ports = { on tile[0]:XS1_PORT_8A };
    s_multi_uart_rx_ports uart_rx_ports = { on tile[0]:XS1_PORT_8B };
    in port p_uart_ref_ext_clk = on tile[0]:XS1_PORT_1A;
    clock clk_uart_rx = on tile[0]: XS1_CLKBLK_1;
    clock clk_uart_tx = on tile[0]: XS1_CLKBLK_2;
  




int main() {
  streaming chan c_tx_uart;
  streaming chan c_rx_uart;
    par {
on tile[0]: 
run_multi_uart_rxtx( c_tx_uart, uart_tx_ports, c_rx_uart, uart_rx_ports, clk_uart_rx,  p_uart_ref_ext_clk, clk_uart_tx);
    
    }
    return 0;
}
