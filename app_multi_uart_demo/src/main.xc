#include <xs1.h>
#include <platform.h>
#include <print.h>
#include "multi_uart_common.h"
#include "multi_uart_rxtx.h"

s_multi_uart_tx_ports uart_tx_ports =
{    
    XS1_PORT_8A,
};
in port uart_ref_ext_clk = XS1_PORT_1A;
clock uart_clock_tx = XS1_CLKBLK_1;

s_multi_uart_rx_ports uart_rx_ports =
{    
    XS1_PORT_8B,
};
clock uart_clock_rx = XS1_CLKBLK_2;

/* do a loopback test with the internal reference clock only - uses non-standard baud rates*/
#define LOOP_REF_TEST

/* do echo test */
//#define ECHO_TEST

/* do simple test */
#define SIMPLE_TEST

/* Reconfiguration enabled for simple test */
//#define SIMPLE_TEST_DO_RECONF

/**
 * Basic test of the TX server - will transmit an identifying message on each UART channel
 */
void uart_tx_test(streaming chanend cUART)
{
    char test_str[8][29] = {"UART Channel 1 Test String\n\0",
        "UART Channel 2 Test String\n\0",
        "UART Channel 3 Test String\n\0",
        "UART Channel 4 Test String\n\0",
        "UART Channel 5 Test String\n\0",
        "UART Channel 6 Test String\n\0",
        "UART Channel 7 Test String\n\0",
        "UART Channel 8 Test String\n\0"};
        
    
    unsigned rd_ptr[8] = {0,0,0,0,0,0,0,0};
    unsigned temp = 0;
    int chan_id = 0;
    #ifdef LOOP_REF_TEST
    unsigned baud_rate = 100000;
    #else
    unsigned baud_rate = 115200;
    #endif
    int buffer_space = 0;
    
    timer t;
    unsigned int ts;

    /* configure UARTs */
    for (int i = 0; i < 8; i++)
    {
        if ((int)baud_rate <= 225)
           baud_rate = 225;
       
       printintln(baud_rate);
       
       if (uart_tx_initialise_channel( i, even, sb_1, baud_rate, 8 ))
       {
           printstr("Invalid baud rate for tx channel ");
           printintln(i);
       }
       //baud_rate >>= 1;
    }
   
   while (temp != MULTI_UART_GO)
   {
       cUART :> temp;
   }
   cUART <: 1;
   
   t :> ts;
   ts += 20 * 100000000; // 20 second

   while (1)
   {
       /* fill buffers with test strings */
       buffer_space = uart_tx_put_char(chan_id, (unsigned int)test_str[chan_id][rd_ptr[chan_id]]);
       
       if (buffer_space != -1)
       {
           if (rd_ptr[chan_id] == 28)
               rd_ptr[chan_id] = 0;
           else
               rd_ptr[chan_id]++;
       }
       chan_id++;
       chan_id &= UART_TX_CHAN_COUNT-1;
       
       /* test reconfiguration every 10s */
       #ifdef SIMPLE_TEST_DO_RECONF
       select
       {
           case t when timerafter(ts) :> ts:
               // cause the system to pause
               uart_tx_reconf_pause( cUART, t );
               
               printstr("reconf\n");
           
               /* configure UARTs - channels 4-7 get changed*/
               baud_rate = 57600;
               if ((int)baud_rate <= 225)
                   baud_rate = 225;
               for (int i = 4; i < 8; i++)
               {
                   printintln(baud_rate);
                   if (uart_tx_initialise_channel( i, even, sb_1, baud_rate, 8 ))
                   {
                       printstr("Invalid baud rate for tx channel ");
                       printintln(i);
                   }
               }
           
               // enable the uart post reconfiguration
               uart_tx_reconf_enable( cUART );
               
               t :> ts;
               /* reset time stamp */
               ts += 20 * 100000000; // 20s
               
               break;
           default:
               break;
       }
       #endif
   }
}

/**
 * Basic test of the RX - will print out a character at a time - will break on continuous 
 * data because of the prints
 */
void uart_rx_test(streaming chanend cUART)
{
    unsigned uart_char, temp;
    #ifdef LOOP_REF_TEST
    unsigned baud_rate = 100000;
    #else
    unsigned baud_rate = 115200;
    #endif
    
    timer t;
    unsigned ts;
    
    
    /* configure UARTs */
    for (int i = 0; i < 8; i++)
    {
        if (uart_rx_initialise_channel( i, even, sb_1, start_0, baud_rate, 8 ))
        {
            printstr("Invalid baud rate for rx channel ");
            printintln(i);
        }
        //baud_rate /= 2;
        if ((int)baud_rate <= 225)
            baud_rate = 225;
    }
    
    /* release UART rx thread */
    do { cUART :> temp; } while (temp != MULTI_UART_GO);
    cUART <: 1;
    
    t :> ts;
    ts += 20 * 100000000; // 20 second
    
    /* main loop */
    while (1)
    {
        int chan_id;
        
        select
        {
            #ifdef SIMPLE_TEST_DO_RECONF // reconfiguration is disabled
            case t when timerafter(ts) :> ts:
                /* pause */
                uart_rx_reconf_pause( cUART );
            
                /* reconfigure */
                // TODO...
            
                /* release UART rx thread */
                uart_rx_reconf_enable( cUART )
            
                t :> ts;
                ts += 20 * 100000000; // 20 second
                break;
            #endif
            
            case cUART :>  chan_id:
                /* get character over channel */
                cUART :> uart_char;
        
                /* process received value */
                temp = uart_char;
                
                if (chan_id == 0)
                {
                    if (uart_rx_validate_char( chan_id, uart_char ) == 0)
                    {
                        printchar(uart_char);
                    }
                }
                break;
        }
    }
}

void dummy()
{
    while (1);
}

/**
 * Top level main for multi-UART demonstration
 */
int main(void)
{
    streaming chan cTxUART;
    streaming chan cRxUART;
    streaming chan cRxBuf;
    
    par
    {
        /* use all 8 threads */
        dummy();
        dummy();
        dummy();
        dummy();
        
        #ifdef SIMPLE_TEST
        /* TX test thread */
        uart_tx_test(cTxUART);
        
        /* RX test thread */
        uart_rx_test(cRxUART);
        #endif
        
        #ifdef ECHO_TEST
        #endif
        
        #ifdef LOOP_REF_TEST
        /* run the multi-uart RX & TX with a common external clock - (2 threads) */
        run_multi_uart_rxtx_int_clk( cTxUART,  uart_tx_ports, cRxUART, uart_rx_ports, uart_clock_rx,  uart_clock_tx);
        #else
        /* run the multi-uart RX & TX with a common external clock - (2 threads) */
        run_multi_uart_rxtx( cTxUART,  uart_tx_ports, cRxUART, uart_rx_ports, uart_clock_rx, uart_ref_ext_clk, uart_clock_tx);
        #endif
    }
    return 0;
}
