// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
Filename: common.h
Project : app_serial_to_ethernet_demo
Author  : XMOS Ltd
Version : 1v0
Purpose : This file delcares data structures and interfaces required for
data manager thread to communicate with application manager thread
-----------------------------------------------------------------------------

===========================================================================*/

/*---------------------------------------------------------------------------
include files
---------------------------------------------------------------------------*/
#ifndef _common_h_
#define _common_h_

/*---------------------------------------------------------------------------
constants
---------------------------------------------------------------------------*/

/* Length of application buffer to hold UART channel data */
#define UART_APP_TX_CHAN_COUNT		8 // Must be Same as UART_TX_CHAN_COUNT
#define TX_CHANNEL_FIFO_LEN			128 //This is a common length between app server and data manager
#define RX_CHANNEL_FIFO_LEN			256


/*---------------------------------------------------------------------------
typedefs
---------------------------------------------------------------------------*/
typedef enum ENUM_BOOL
{
    FALSE = 0,
    TRUE,
} e_bool;

typedef enum ENUM_TEXT_MSGS
{
	IDX_USAGE_HELP = 0,
	NUM_TX_TRACE_MSGS,
}e_tx_text_msgs;

/*---------------------------------------------------------------------------
extern variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
global variables
---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
prototypes
---------------------------------------------------------------------------*/

#endif // _common_h_
