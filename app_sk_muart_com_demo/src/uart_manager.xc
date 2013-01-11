// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/* This file implements UART application manager to cater to
 * different features supported by UART demo such as
 * file transfers using a single UART and across all UARTs,
 * UART reconfiguration to a different baud rate setting etc */

#include <xs1.h>
#include "multi_uart_tx.h"
#include "multi_uart_rx.h"
#include "multi_uart_common.h"
#include "xc_ptr.h"
#include "uart_manager.h"
#include <print.h>

/* Data structure to hold UART data */
typedef struct STRUCT_UART_BUFFER
{
	unsigned int 	uart_id;						//UART identifier
	int 			read_index;						//Consumed data level
	int 			write_index;					//Filled data level
	unsigned 		buf_depth;						//Data remaining
	char			uart_data[UART_FIFO_LEN];	// UART buffer
}s_uart_buffer;

s_uart_buffer uart_buffer_state[UART_RX_CHAN_COUNT];

char multi_uart_welcome_msg[] = "Welcome to MUART Slice Card demo\r\n Choose one of the following options \r\n e - echo data \r\n r - UART reconfiguration \r\n f - file transfer \r\n b - pipe file on all uart channels \r\n h - usage help\r\n";
char multi_uart_help_menu[] = "Choose one of the following options \r\n e - echo data \r\n r - UART reconfiguration \r\n f - file transfer \r\n b - pipe file on all uart channels \r\n h - usage help\r\n";
char multi_uart_echo_mode[] = "UART now echoes back the data entered\r\n";
char multi_uart_command_mode[] = "UART is in Command mode. Press 'h' for help\r\n";
char multi_uart_invalid_choice[] = "Invalid choice. Press 'h' for help\r\n";
char multi_uart_baud_selection[] = "Choose \r\n 1 for 115200 baud \r\n 2 for 57600 baud \r\n 3 for 9600 baud \r\n 4 for 600 baud \r\n";
char multi_uart_invalid_baud_selection[] = "Invalid selection. Choose either 1, 2, 3, 4 or press 'Esc' to return to main menu\r\n";
char multi_uart_restart_console[] = "Restart serial console with new baud rate setting \r\n";
char multi_uart_file_upload[] = "Upload a file and press CTRL+D. Press 'Esc' to return to main menu \r\n";
char multi_uart_pipe_broken[] = "MultiUART Pipe Broken, Check Hardware\r\n";
/* Flag to send messages from UART 0 to host serial console */
unsigned uart_console_msg_ready;

/* Initialize UART buffers to default values */
static void init_uart_buffers()
{
    for(int i = 0; i < UART_RX_CHAN_COUNT; i++)
    {
        /* UART Buffers initialization */
        uart_buffer_state[i].uart_id = i;
        uart_buffer_state[i].read_index = 0;
        uart_buffer_state[i].write_index = 0;
        uart_buffer_state[i].buf_depth = 0;
    }
}

/* This function stores UART data received from
 * UART RX server into application buffers */
#pragma unsafe arrays
static void store_byte_into_uart_buffer(s_uart_buffer &st,
                                   unsigned uart_char)
{
    if(st.buf_depth < UART_FIFO_LEN)
    {
        write_byte_via_xc_ptr_indexed(st.uart_data,
        		                      st.write_index,
                                      uart_char);
        st.write_index++;
        if(st.write_index >= UART_FIFO_LEN) {
        	st.write_index = 0;
        }
        st.buf_depth++;
    }
  return;
}

/* This function pushes data from UART application buffers to
 * UART TX server */
void send_byte_from_uart_buffer(s_uart_buffer &st)
{
    int buffer_space = 0;
    int data;

    if ((st.buf_depth > 0) && (st.buf_depth <= UART_FIFO_LEN))
    {
        read_byte_via_xc_ptr_indexed(data, st.uart_data, st.read_index);
//::Send Byte
        buffer_space = uart_tx_put_char(st.uart_id, (unsigned int)data);
        if(-1 != buffer_space)
        {
            /* Data is sent to uart successfully */
        	st.read_index++;
            if(st.read_index >= UART_FIFO_LEN) {
            	st.read_index = 0;
            }
            st.buf_depth--;
        } // if(-1 != buffer_space)
//::Send Byte End
    } // if ((st.buf_depth > 0) && (st.buf_depth <= UART_FIFO_LEN))
}

/* This function sends messages to UART TX server.
 * These will be displayed in host console */
static void send_console_msg(char msg_array[])
{
	int i = 0;
	while ('\0' != msg_array[i]) {
		store_byte_into_uart_buffer(uart_buffer_state[0], msg_array[i]);
		i++;
	}
	uart_console_msg_ready = 1;
}

/**
 *  This is the main UART application handler. It maintains
 *  application state, interfaces to MUART TX and RX servers,
 *  handles application logic to store and send UART data across all
 *  configured UARTs
 */
void uart_app_manager(streaming chanend c_tx_uart, streaming chanend c_rx_uart)
{
    char rx_channel_id;
    char temp;
    unsigned uart_id = 0;
    unsigned uart_id_to_reconfig = 0;
    int uart_baud = 115200;
    int tx_ready = 0;
    int pipe_count = 0;

    /* Command mode flag enables UART to receive menu options */
    unsigned uart_cmd_mode = 1;
    /* reconfig flag indicates presence of UART reconfig request */
    unsigned uart_reconfig = 0;

    init_uart_buffers();
//::Init Start
    /* configure UARTs */
    for (int i = 0; i < UART_RX_CHAN_COUNT; i++)
    {
        if (uart_tx_initialise_channel( i, even, sb_1, start_0, uart_baud, 8 ))
        {
            printstr("Uart TX configuration failed for channel: ");
            printintln(i);
        }

        if (uart_rx_initialise_channel( i, even, sb_1, start_0, uart_baud, 8 ))
        {
            printstr("Uart RX configuration failed for channel: ");
            printintln(i);
        }
    }
//::Init End

//::Muart server
    /* Release UART RX server */
    do { c_rx_uart :> temp;} while (temp != MULTI_UART_GO); c_rx_uart <: 1;
    /* Release UART TX server */
    do { c_tx_uart :> temp;} while (temp != MULTI_UART_GO); c_tx_uart <: 1;
//::Muart end

    printstr("Demo app running with baud rate: ");
    printintln(uart_baud);

    send_console_msg(multi_uart_welcome_msg);

    // Loop forever processing Tx and Rx UART data
    while(1)
    {
//::Receive Data
        select
        {
#pragma ordered
            case c_rx_uart :> rx_channel_id:
            {
                unsigned uart_char;

                uart_char = (unsigned)uart_rx_grab_char(rx_channel_id);
                if(uart_rx_validate_char(rx_channel_id, uart_char) == 0) {
//:: Receive Data End
                	/* Reset flag variables when Esc is presed */
                	if ((0x1b == uart_char) && (0 == rx_channel_id)) {
                		send_console_msg(multi_uart_command_mode);
                		uart_cmd_mode = 1;
                		tx_ready = 0;
                		break;
                	}

                	if (1 == uart_cmd_mode) {
                		if (uart_char == 'h') {
                			send_console_msg(multi_uart_help_menu);
                			uart_cmd_mode = 1;
                		}
                		else if (uart_char == 'e') {
                			send_console_msg(multi_uart_echo_mode);
                			uart_cmd_mode = 2;
                		}
                		else if (uart_char == 'f') {
                			send_console_msg(multi_uart_file_upload);
                			uart_cmd_mode = 3;
                		}
                		else if (uart_char == 'b') {
                			send_console_msg(multi_uart_file_upload);
                			uart_cmd_mode = 4;
                		}
                		else if (uart_char == 'r') {
                			send_console_msg(multi_uart_baud_selection);
                			uart_cmd_mode = 5;
                		}
                		else {
                			send_console_msg(multi_uart_invalid_choice);
                			uart_cmd_mode = 1;
                		}
                		break;
                	}

                	/* Send UART TX data when CTRL+D is pressed */
                	if ((0x04 == uart_char) && (0 == rx_channel_id)) {
                		tx_ready = 1;
                		pipe_count = 0;
                	}

                	if (2 == uart_cmd_mode) { // echo mode
                		uart_tx_put_char(rx_channel_id, (unsigned int)uart_char);
                	}
                	else if (3 == uart_cmd_mode) { // file transfers on UART x
                    	store_byte_into_uart_buffer(uart_buffer_state[(unsigned)rx_channel_id], uart_char);
                	}
                	else if (4 == uart_cmd_mode) { //Pipe data on all UARTs
                    	if ((UART_RX_CHAN_COUNT-1) != rx_channel_id) {
                    		store_byte_into_uart_buffer(uart_buffer_state[rx_channel_id+1], uart_char);
                    		/* Spl pipe case: As we do not precisely know if all data is piped out,
                    		 * Stop sending any pipe data if data on incoming pipe is started */
                    		if ((0 == rx_channel_id) && (1 == uart_buffer_state[rx_channel_id+1].buf_depth)) {
                    			if ((UART_RX_CHAN_COUNT != pipe_count) && (tx_ready))
                    				send_console_msg(multi_uart_pipe_broken);
                    			tx_ready = 0;
                    			pipe_count = 0;
                    		}
                    	}
                    	else
                    		store_byte_into_uart_buffer(uart_buffer_state[0], uart_char);

                    	if (0x04 == uart_char) { //CTRL+D
                    		pipe_count++;
                    	}
                	} //(4 == uart_cmd_mode)
                	else if (5 == uart_cmd_mode) { // reconfigure UART baud rate
                		if ((('1' == uart_char) && (uart_baud = 115200)) ||
                				(('2' == uart_char) && (uart_baud = 57600)) ||
                					(('3' == uart_char) && (uart_baud = 9600)) ||
                						(('4' == uart_char) && (uart_baud = 600)) ) {
                    	    send_console_msg(multi_uart_restart_console);
                    	    uart_reconfig = 1;
                    	    uart_id_to_reconfig = rx_channel_id;
                    	    uart_cmd_mode = 1;
                		} else {
                    	    send_console_msg(multi_uart_invalid_baud_selection);
                		}
                	}
                } //if(uart_rx_validate_char(rx_channel_id, uart_char) == 0)
            }
                break;
            default:
            	if (tx_ready) {
                	/* File transfers on UART x */
            		if ((3 == uart_cmd_mode) && (0 == uart_id)) {
            			send_byte_from_uart_buffer(uart_buffer_state[uart_id]);

                		if (uart_buffer_state[uart_id].buf_depth == 0)
                			tx_ready = 0;
            		}
                	/* Pipe data on all UARTs */
            		else if (4 == uart_cmd_mode) {
                    	if ((UART_RX_CHAN_COUNT-1) != uart_id) {
                			/* Pipe data to next UART i.e. say for Uart 0, Rx stores in Buffer 1,
                			 * so during TX, move data from buf 1 to buf 2 and so on */
                    		send_byte_from_uart_buffer(uart_buffer_state[uart_id+1]);
                    	}
                    	else
                    		send_byte_from_uart_buffer(uart_buffer_state[0]);
            		}
            	}

            	/* Send any messages to UART console */
            	if ((uart_console_msg_ready) && (0 == uart_id)) {
            		send_byte_from_uart_buffer(uart_buffer_state[0]);

            		if (uart_buffer_state[0].buf_depth == 0)
            			uart_console_msg_ready = 0;
            	}

            	/* Reconfigure UART if its a valid request and no pending console messages to display */
            	if ((uart_reconfig) && (0 == uart_console_msg_ready)) {
            	    timer t;
//::Reconfig Start
            	    uart_tx_reconf_pause(c_tx_uart, t);
            	    uart_rx_reconf_pause(c_rx_uart);
            	    uart_tx_initialise_channel( uart_id_to_reconfig, even, sb_1, start_0, uart_baud, 8 );
            	    uart_rx_initialise_channel( uart_id_to_reconfig, even, sb_1, start_0, uart_baud, 8 );
            	    uart_tx_reconf_enable(c_tx_uart);
            	    uart_rx_reconf_enable(c_rx_uart);
//::Reconfig End
            		uart_reconfig = 0;
            		init_uart_buffers();
            	    printstr("Demo app running with reconfigured baud rate: ");
            	    printintln(uart_baud);
            	}

            	/* Loop through all UARTs */
            	uart_id++;
                if (uart_id >= UART_RX_CHAN_COUNT)
                	uart_id = 0;
                break;
        } // select
    } // while(1)
}
