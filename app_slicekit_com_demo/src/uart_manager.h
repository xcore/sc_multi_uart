// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
Filename: uart_manager.h
Project : app_serial_to_ethernet_demo
Author  : XMOS Ltd
Version : 1v0
Purpose : This file delcares data structures and interfaces required for
application manager thread to communicate with http and telnet clients,
and multi-uart tx and rx threads
-----------------------------------------------------------------------------

===========================================================================*/

/*---------------------------------------------------------------------------
include files
---------------------------------------------------------------------------*/
#ifndef _uart_manager_h_
#define _uart_manager_h_
#include "multi_uart_tx.h"
#include "multi_uart_rx.h"
#include "multi_uart_common.h"
#include "common.h"
/*---------------------------------------------------------------------------
constants
---------------------------------------------------------------------------*/
#define	ERR_UART_CHANNEL_NOT_FOUND	50
#define	ERR_CHANNEL_CONFIG			60
/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/
/* Data structure to hold received UART data */
typedef struct STRUCT_UART_RX_CHANNEL_FIFO
{
	unsigned int 	channel_id;						//Channel identifier
	char			channel_data[RX_CHANNEL_FIFO_LEN];	// Data buffer
	int 			read_index;						//Index of consumed data
	int 			write_index;					//Input data to Tx api
	unsigned 		buf_depth;						//depth of buffer to be consumed
	e_bool			is_currently_serviced;			//T/F: Indicates whether channel is just
    int             last_added_timestamp;           // A timestamp of when the an item was last added to the fifo
													// serviced; if T, select next channel
    int             consume_data;
}s_uart_rx_channel_fifo;

/** Data structure to hold uart config data */
typedef struct STRUCT_UART_CHANNEL_CONFIG
{
	unsigned int 			channel_id;				//Channel identifier
	e_uart_config_parity	parity;
	e_uart_config_stop_bits	stop_bits;
	int						baud;					//configured baud rate
	int 					char_len;				//Length of a character in bits (e.g. 8 bits)
	e_uart_config_polarity  polarity;        		//polarity of start bits
} s_uart_channel_config;

/*---------------------------------------------------------------------------
extern variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
global variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/
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

void uart_manager(streaming chanend c_tx_uart,
		streaming chanend c_rx_uart);

#endif // _uart_manager_h_
