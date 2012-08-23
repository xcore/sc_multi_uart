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

//:demo_app_config
/* Define number of UARTs to be configured */
#define NUM_ACTIVE_UARTS			UART_RX_CHAN_COUNT
/* Define length of application buffer (in bytes) to hold received UART data */
#define RX_CHANNEL_FIFO_LEN			1024
//:
#define CONSOLE_MSGS_MAX_MEN		200

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
	IDX_WELCOME_USAGE,
	IDX_ECHO_MODE_MSG,
	IDX_RECONF_MODE_MSG,
	IDX_RECONF_SUCCESS_MSG,
	IDX_RECONF_FAIL_MSG,
	IDX_PUT_FILE_MSG,
	IDX_FILE_DATA_LOST_MSG,
	IDX_INVALID_PUT_REQUEST,
	IDX_FILE_STATS,
	IDX_CMD_MODE_MSG,
	IDX_DATA_MODE_MSG,
	IDX_INVALID_USAGE,
	NUM_CONSOLE_MSGS,
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
