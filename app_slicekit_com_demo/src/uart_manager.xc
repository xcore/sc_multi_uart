// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: uart_manager.xc
 Project : app_serial_to_ethernet_demo
 Author  : XMOS Ltd
 Version : 1v0
 Purpose : This file implements state machine to handle http requests and
 connection state management and functionality to interface http client
 (mainly application and uart channels configuration) data
 -----------------------------------------------------------------------------

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <xs1.h>
#include "uart_manager.h"
#include "common.h"
#include "xc_ptr.h"
#include "util.h"

#define ENABLE_XSCOPE 1

#if ENABLE_XSCOPE == 1
#include <print.h>
#include <xscope.h>
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define	MAX_BIT_RATE					115200      //100000    //bits per sec
	/* Default length of a uart character in bits */
#define	DEF_CHAR_LEN					8
#define MAX_BAUD_RATE_INDEX				7

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef enum {
  UART_MODE_CMD=0,
  UART_MODE_DATA,
} uart_mode_t;

typedef enum {
  UART_CMD_ECHO_DATA='e',
  UART_CMD_ECHO_HELP='h',
  UART_CMD_UART_RECONF='r',
  UART_CMD_PUT_FILE='p',
  UART_CMD_GET_FILE='g',
  UART_CMD_PIPE_FILE='b',
} uart_usage_mode_t;

typedef struct uart_mode_state_t {
  unsigned int uart_id;
  uart_mode_t  uart_mode;
  uart_usage_mode_t uart_usage_mode;
}uart_comm_state_t;

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
s_uart_channel_config uart_channel_config[UART_TX_CHAN_COUNT];
s_uart_rx_channel_fifo uart_rx_channel_state[UART_RX_CHAN_COUNT];
uart_comm_state_t uart_comm_state[UART_RX_CHAN_COUNT];
int valid_baud_rate[MAX_BAUD_RATE_INDEX]={115200, 57600, 38400, 19200, 9600, 4800, 600};
/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/

/** =========================================================================
 *  uart_channel_init
 *
 *  Initialize Uart channels data structure
 *
 *  \param		None
 *
 *  \return		None
 *
 **/
static void uart_channel_init(void)
{
    int i;

    for(i = 0; i < UART_TX_CHAN_COUNT; i++)
    {
        // Initialize Uart channels configuration data structure
        uart_channel_config[i].channel_id = i;
        uart_channel_config[i].parity = even;
        uart_channel_config[i].stop_bits = sb_1;
        uart_channel_config[i].baud = MAX_BIT_RATE;
        uart_channel_config[i].char_len = DEF_CHAR_LEN;
        uart_channel_config[i].polarity = start_0;
    }
}

/** =========================================================================
 *  init_uart_channel_state
 *
 *  Initialize Uart channels state to default values
 *
 *  \param			None
 *
 *  \return			None
 *
 **/
static void init_uart_channel_state(void)
{
    int i;
    /* Assumption: UART_TX_CHAN_COUNT == UART_TX_CHAN_COUNT always */
    for(i = 0; i < UART_TX_CHAN_COUNT; i++)
    {
        /* RX initialization */
        uart_rx_channel_state[i].channel_id = i;
        uart_rx_channel_state[i].read_index = 0;
        uart_rx_channel_state[i].write_index = 0;
        uart_rx_channel_state[i].buf_depth = 0;
        uart_rx_channel_state[i].consume_data = 0;
    } //for (i=0;i<UART_TX_CHAN_COUNT;i++)
}

/** =========================================================================
 *  configure_uart_channel
 *  invokes MUART component api's to initialze MUART Tx and Rx threads
 *
 *  \param unsigned int	Uart channel identifier
 *
 *  \return		0 		on success
 *
 **/
static int configure_uart_channel(unsigned int channel_id)
{
    int chnl_config_status = ERR_CHANNEL_CONFIG;

    chnl_config_status = uart_tx_initialise_channel(uart_channel_config[channel_id].channel_id,
                                                    uart_channel_config[channel_id].parity,
                                                    uart_channel_config[channel_id].stop_bits,
                                                    uart_channel_config[channel_id].polarity,
                                                    uart_channel_config[channel_id].baud,
                                                    uart_channel_config[channel_id].char_len);

    chnl_config_status |= uart_rx_initialise_channel(uart_channel_config[channel_id].channel_id,
                                                     uart_channel_config[channel_id].parity,
                                                     uart_channel_config[channel_id].stop_bits,
                                                     uart_channel_config[channel_id].polarity,
                                                     uart_channel_config[channel_id].baud,
                                                     uart_channel_config[channel_id].char_len);
    return chnl_config_status;
}

/** =========================================================================
 *  apply_default_uart_cfg_and_wait_for_muart_tx_rx_threads
 *
 *  Apply default uart channels configuration and wait for
 *  MULTI_UART_GO signal from MUART_RX and MUART_RX threads
 *
 *  \param	chanend c_tx_uart		channel end sharing channel to MUART TX thrd
 *
 *  \param	chanend c_rx_uart		channel end sharing channel to MUART RX thrd
 *
 *  \return			None
 *
 **/
static void apply_default_uart_cfg_and_wait_for_muart_tx_rx_threads(streaming chanend c_tx_uart,
                                                                    streaming chanend c_rx_uart)
{
    int channel_id;
    int chnl_config_status = 0;
    char temp;
    for(channel_id = 0; channel_id < UART_TX_CHAN_COUNT; channel_id++)
    {
        chnl_config_status = configure_uart_channel(channel_id);
        if(0 != chnl_config_status)
        {
            printstr("Uart configuration failed for channel: ");
            printintln(channel_id);
            chnl_config_status = 0;
        }
        else
        {
//#ifdef DEBUG_LEVEL_3
            printstr("Successful Uart configuration for channel: ");
            printintln(channel_id);
//#endif //DEBUG_LEVEL_3
        }
    } // for(channel_id = 0; channel_id < UART_TX_CHAN_COUNT; channel_id++)
    /* Release UART rx thread */
    do { c_rx_uart :> temp;} while (temp != MULTI_UART_GO); c_rx_uart <: 1;
    /* Release UART tx thread */
    do { c_tx_uart :> temp;} while (temp != MULTI_UART_GO); c_tx_uart <: 1;
}


/** =========================================================================
 *  send_byte_to_uart_tx
 *
 *  This function primarily handles UART TX buffer overflow condition by
 *  storing data into its application buffer when UART Tx buffer is full
 *  This function reads data from uart channel specific application TX buffer
 *  and invokes MUART TX api to send to uart channel of MUART TX component
 *
 *  \param 			None
 *
 *  \return			None
 *
 **/
void send_byte_to_uart_tx(s_uart_rx_channel_fifo &st)
{
    int buffer_space = 0;
    int data;

    if ((st.buf_depth > 0) && (st.buf_depth <= RX_CHANNEL_FIFO_LEN))
    {
        read_byte_via_xc_ptr_indexed(data, st.channel_data, st.read_index);

        buffer_space = uart_tx_put_char(st.channel_id, (unsigned int)data);
        if(-1 != buffer_space)
        {
            /* Data is pushed to uart successfully */
        	st.read_index++;
            if(st.read_index >= RX_CHANNEL_FIFO_LEN) {
            	st.read_index = 0;
            }
            st.buf_depth--;

            if (0 == st.buf_depth) {
            	st.consume_data = 0;
            }
        } // if(-1 != buffer_space)
    } // if ((st.buf_depth > 0) && (st.buf_depth <= RX_CHANNEL_FIFO_LEN))
}

/** =========================================================================
 *  re_apply_uart_channel_config
 *
 *  This function either configures or reconfigures a uart channel
 *
 *  \param	s_uart_channel_config sUartChannelConfig Reference to UART conf
 *
 *  \param	chanend c_tx_uart		channel end sharing channel to MUART TX thrd
 *
 *  \param	chanend c_rx_uart		channel end sharing channel to MUART RX thrd
 *
 *  \return			None
 *
 **/
#pragma unsafe arrays
static int re_apply_uart_channel_config(int channel_id,
                                        streaming chanend c_tx_uart,
                                        streaming chanend c_rx_uart)
{
    int ret_val = 0;
    int chnl_config_status = 0;
    timer t;

    uart_tx_reconf_pause(c_tx_uart, t);
    uart_rx_reconf_pause(c_rx_uart);
    chnl_config_status = configure_uart_channel(channel_id);
    uart_tx_reconf_enable(c_tx_uart);
    uart_rx_reconf_enable(c_rx_uart);
    /*
    if(0 != chnl_config_status)
    {
        printint(channel_id);
        printstrln(": Channel reconfig failed");
    }
    */
    //TODO: Send response back on the channel
}

#pragma unsafe arrays
static void push_byte_to_uart_rx_buffer(s_uart_rx_channel_fifo &st,
                                   unsigned uart_char)
{
    if(st.buf_depth < RX_CHANNEL_FIFO_LEN)
    {
        write_byte_via_xc_ptr_indexed(st.channel_data,
        		                      st.write_index,
                                      uart_char);
        st.write_index++;
        if(st.write_index >= RX_CHANNEL_FIFO_LEN) {
        	st.write_index = 0;
        }

        st.buf_depth++;
        //tmr :> st.last_added_timestamp;
    }
    else
    {
    	st.consume_data = 1;
#if ENABLE_XSCOPE == 1
        // Drop data due to buffer overflow
        printchar('!');
#endif
    }
  return;
}

static int validate_uart_baud(int baud)
{
	for (int i=0; i<MAX_BAUD_RATE_INDEX; i++) {
		if (baud == valid_baud_rate[i])
			return 1;
	}

	return 0;
}

static int validate_uart_cmd(char uart_cmd)
{
	if (1) {

	}
}

static void uart_state_hanlder(char uart_id, unsigned uart_char,
        streaming chanend c_tx_uart,
        streaming chanend c_rx_uart)
{
	static int iter_index = 0;
	static int get_file = 0;

	if (0x1b == uart_char) { //'ESC' char is received
		uart_comm_state[uart_id].uart_mode = 1 - uart_comm_state[uart_id].uart_mode; //Toggle between command and data mode
		/* Send back help info to user via tx api */
		return;
	}

	if (UART_MODE_CMD == uart_comm_state[uart_id].uart_mode) {
		//TODO: Validate UART command mode;
		// if get_file: no echo_data and get_file possible; reset relevant flags (get_file etc)
		// else send appropriate error messages to user
		validate_uart_cmd(uart_char);
		switch (uart_char) {
		case 'e':
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_DATA;
			break;
		case 'h':
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_HELP;
			uart_rx_channel_state[uart_id].read_index = 0;//TODO:to get into validate_cmd function
			uart_rx_channel_state[uart_id].write_index = 0;
			uart_rx_channel_state[uart_id].buf_depth = 0;
			break;
		case 'r':
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_UART_RECONF;
			break;
		case 'p':
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_PUT_FILE;
			break;
		case 'g':
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_GET_FILE;
			uart_rx_channel_state[uart_id].read_index = 0;//TODO:to get into validate_cmd function
			uart_rx_channel_state[uart_id].write_index = 0;
			uart_rx_channel_state[uart_id].buf_depth = 0;
			break;
		case 'b':
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_PIPE_FILE;
			break;
		default:
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_DATA;
			break;
		}
		uart_comm_state[uart_id].uart_mode = UART_MODE_DATA;
		iter_index = 0;
		return;
	}

	switch (uart_comm_state[uart_id].uart_usage_mode) {
	case UART_CMD_ECHO_DATA:
	    push_byte_to_uart_rx_buffer(uart_rx_channel_state[uart_id], uart_char);
		break;
	case UART_CMD_ECHO_HELP:
	{
		int len = string_copy(uart_rx_channel_state[uart_id].channel_data[0], IDX_USAGE_HELP);
		uart_rx_channel_state[uart_id].buf_depth += len;
		uart_rx_channel_state[uart_id].write_index += len;
		uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_DATA;
	}
		break;
	case UART_CMD_UART_RECONF:
	{
		static char baud[10] = "";
		int user_baud = 0;

		if ((iter_index < 10) && (0xd != uart_char)) {
			baud[iter_index] = uart_char;
			iter_index++;
		}
		else if (0xd == uart_char) { //'Carriage Return' is received
			baud[iter_index] = '\0';
			user_baud = atoi(baud);

			if (validate_uart_baud(user_baud)) {
				uart_channel_config[(int)uart_id].baud = user_baud;
				re_apply_uart_channel_config((int)uart_id, c_tx_uart, c_rx_uart);
			}
			iter_index = 0;
		}
		else
			iter_index = 0;

	}
		break;
	case UART_CMD_PUT_FILE:
		if (get_file) {
			get_file = 0;
			/* Start timer for file transfer */
		}
		else {
			/* No file received in buffer. Send back msg to user */
		}
		break;
	case UART_CMD_GET_FILE:
		/* Copy the file contents into buffer */
		//if (0 == uart_rx_channel_state[uart_id].buf_depth)
			/* Start the get timer */ //TODO: start timer

		if (0x04 != uart_char) {
			push_byte_to_uart_rx_buffer(uart_rx_channel_state[uart_id], uart_char);
		}
		else {
			//push_byte_to_uart_rx_buffer(uart_rx_channel_state[uart_id], uart_char);
			if (1) //(check_crc(uart_rx_channel_state[uart_id]))
				get_file = 1;
			/* End the get timer */
			//TODO: /* Send user msg on receive timing */
		}
		/* validate crc and mark validity of the file */
		/* time the transfer */
		break;
	case UART_CMD_PIPE_FILE:
		/* receive file, pipe it to all channels and validate it */
		/* time the transfer */
		break;
	}
    //push_byte_to_uart_rx_buffer(uart_rx_channel_state[uart_id], uart_char);
}

static void uart_tx_hanlder(int uart_id)
{
	switch (uart_comm_state[uart_id].uart_usage_mode) {
	case UART_CMD_ECHO_DATA:
	case UART_CMD_ECHO_HELP:
	case UART_CMD_PUT_FILE:
		send_byte_to_uart_tx(uart_rx_channel_state[uart_id]);
		break;
	}

}

/** 
 *  The multi uart manager thread. This thread
 *  (i) periodically polls for data on application Tx buffer, in order to transmit to telnet clients
 *  (ii) waits for channel data from MUART Rx thread
 *
 *  \param	chanend cWbSvr2AppMgr channel end sharing web server thread
 *  \param	chanend c_tx_uart		channel end sharing channel to MUART TX thrd
 *  \param	chanend c_rx_uart		channel end sharing channel to MUART RX thrd
 *  \return	None
 *
 */
void uart_manager(streaming chanend c_tx_uart, streaming chanend c_rx_uart)
{
    timer txTimer;
    char rx_channel_id;
    int write_index;
    int uart_id = 0;

#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    /* Applying default UART configuration */
    uart_channel_init();
    init_uart_channel_state();
    apply_default_uart_cfg_and_wait_for_muart_tx_rx_threads( c_tx_uart, c_rx_uart);

    // Loop forever processing Tx and Rx UART data
    while(1)
    {
        select
        {
#pragma ordered
            case c_rx_uart :> rx_channel_id:
            {
                unsigned uart_char;

                uart_char = (unsigned)uart_rx_grab_char(rx_channel_id);
                if(uart_rx_validate_char(rx_channel_id, uart_char) == 0) {
                	uart_state_hanlder(rx_channel_id, uart_char, c_tx_uart, c_rx_uart);
                }
                break;
            }

            default:
            	uart_tx_hanlder(uart_id);

            	uart_id++;
                if (uart_id >= UART_TX_CHAN_COUNT)
                	uart_id = 0;

                break;
        } // select
    } // while(1)
}

