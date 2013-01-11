// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
Filename: uart_manager.h
Project : app_sk_muart_com_demo
Author  : XMOS Ltd
Version : 1v0
Purpose : This file delcares data structures and interfaces required for
uart application manager
===========================================================================*/
#ifndef _uart_manager_h_
#define _uart_manager_h_

//:demo_app_config
/* Define length of application buffer (in bytes) to hold received UART data */
#define UART_FIFO_LEN			1024
//:

/**
 *  This is the main UART application handler. It maintains
 *  application state, interfaces to MUART TX and RX servers,
 *  handles application logic to store and send UART data across all
 *  configured UARTs
 */
void uart_app_manager(streaming chanend c_tx_uart,
		streaming chanend c_rx_uart);

#endif // _uart_manager_h_
