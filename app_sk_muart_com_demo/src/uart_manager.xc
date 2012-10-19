// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Filename: uart_manager.xc
 Project : app_sk_muart_com_demo
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

//#define ENABLE_XSCOPE 1
#ifndef ENABLE_XSCOPE
#include <print.h>
#endif

#if ENABLE_XSCOPE == 1
#include <print.h>
#include <xscope.h>
#endif

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define	MAX_BIT_RATE					115200      //bits per sec
	/* Default length of a uart character in bits */
#define	DEF_CHAR_LEN					8
#define MAX_BAUD_RATE_INDEX				7
#define CRC_INDICATOR					'#'
#define CRC_CHAR_LIMIT					10
#define DELAY_CHAR_SEND					2000
//at higher baud rate limiting the transmit data rate to give room to rx for processing the received byte using loopback
/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
typedef enum {
  UART_MODE_CMD=0, //Uart is in Command mode
  UART_MODE_DATA, //Uart is in DATA mode
} uart_mode_t;

typedef enum { //Input options
  UART_CMD_ECHO_DATA='e',
  UART_CMD_ECHO_HELP='h',
  UART_CMD_UART_RECONF='r',
  UART_CMD_PUT_FILE='p',
  UART_CMD_GET_FILE='g',
  UART_CMD_PIPE_FILE='b',
  UART_CMD_PIPE_FILE_RCV='c',
  UART_CMD_PIPE_FILE_IDLE='k',
  UART_CMD_INVALID = 'i',
} uart_usage_mode_t;

typedef struct uart_mode_state_t {
  unsigned int uart_id;
  unsigned int welcome_msg_sent;
  unsigned int pending_file_transfer;
  unsigned int get_ts;
  unsigned int put_ts;
  uart_mode_t  uart_mode;
  uart_usage_mode_t uart_usage_mode;
}uart_comm_state_t;

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
s_uart_channel_config uart_channel_config[NUM_ACTIVE_UARTS];
s_uart_rx_channel_fifo uart_rx_channel_state[NUM_ACTIVE_UARTS];
uart_comm_state_t uart_comm_state[NUM_ACTIVE_UARTS];
int valid_baud_rate[MAX_BAUD_RATE_INDEX]={115200, 57600, 38400, 19200, 9600, 4800, 600};
unsigned Char_length=1,Channel_ID=1,INITIAL=1,num_chr_received=0;
timer tmr;
unsigned time_start,time_end;
/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 implementation
 ---------------------------------------------------------------------------*/

/** =========================================================================
 *  init_uart
 *
 *  Initialize Uart channels state to default values
 *
 *  \param			None
 *
 *  \return			None
 *
 **/
//::Init Start
static void init_uart_parameters(void)
{
    int i;
    /* Assumption: NUM_ACTIVE_UARTS == NUM_ACTIVE_UARTS always */
    for(i = 0; i < NUM_ACTIVE_UARTS; i++)
    {
        // Initialize Uart channels configuration data structure
        uart_channel_config[i].channel_id = i;
        uart_channel_config[i].parity = even;
        uart_channel_config[i].stop_bits = sb_1;
        uart_channel_config[i].baud = MAX_BIT_RATE;
        uart_channel_config[i].char_len = DEF_CHAR_LEN;
        uart_channel_config[i].polarity = start_0;

        /* RX initialization */
        uart_rx_channel_state[i].channel_id = i;
        uart_rx_channel_state[i].read_index = 0;
        uart_rx_channel_state[i].write_index = 0;
        uart_rx_channel_state[i].buf_depth = 0;

        uart_comm_state[i].uart_id = i;
        uart_comm_state[i].welcome_msg_sent = 0;
        uart_comm_state[i].pending_file_transfer = 0;
        uart_comm_state[i].get_ts = 0;
        uart_comm_state[i].put_ts = 0;
        uart_comm_state[i].uart_usage_mode = UART_CMD_ECHO_HELP; //Set add uart channels to Echo help mode
        uart_comm_state[i].uart_mode = UART_MODE_CMD;
    }
}
//::Init End

/** =========================================================================
 *  configure_uart_channel
 *  invokes MUART component api's to initialze MUART Tx and Rx threads
 *
 *  \param unsigned int	Uart channel identifier
 *
 *  \return		0 		on success
 *
 **/
 
static int configure_uart_channel(unsigned uart_id)
{
    int chnl_config_status = ERR_CHANNEL_CONFIG;
	//Initialise Uart TX channels
    chnl_config_status = uart_tx_initialise_channel(uart_channel_config[uart_id].channel_id,
                                                    uart_channel_config[uart_id].parity,
                                                    uart_channel_config[uart_id].stop_bits,
                                                    uart_channel_config[uart_id].polarity,
                                                    uart_channel_config[uart_id].baud,
                                                    uart_channel_config[uart_id].char_len);
	//Initialise Uart Rx channels
    chnl_config_status |= uart_rx_initialise_channel(uart_channel_config[uart_id].channel_id,
                                                     uart_channel_config[uart_id].parity,
                                                     uart_channel_config[uart_id].stop_bits,
                                                     uart_channel_config[uart_id].polarity,
                                                     uart_channel_config[uart_id].baud,
                                                     uart_channel_config[uart_id].char_len);
    return chnl_config_status;
}

/** =========================================================================
 *  send_message_to_uart_console
 *
 *  Sends messages to Uart TX pins based on message state and channel ID
 *
 *  \param			uart_id		Uart Channel ID
 *  \param			message_id	Message to be displayed on Uart Channel
 *
 *  \return			None
 *
 **/

static void send_message_to_uart_console(unsigned uart_id, int msg_id)
{
	int len = 0;
	//Clear all buffers and copy message to aUart buffers
	uart_rx_channel_state[uart_id].read_index = 0; 
	uart_rx_channel_state[uart_id].write_index = 0;
	uart_rx_channel_state[uart_id].buf_depth = 0; //Clear all buffer data

	len = copy_console_message(uart_rx_channel_state[uart_id].channel_data[0], msg_id); //Find length of message

	uart_rx_channel_state[uart_id].buf_depth += len;
	uart_rx_channel_state[uart_id].write_index += len;
}

/** =========================================================================
 *  append_to_uart_console_message
 *
 *  Appends messages to Uart buffer based on message mode and channel ID
 *
 *  \param			uart_id		Uart Channel ID
 *
 *  \param			mode		checks for parameter data or not
 *
 *  \param			mesage_id	append string to the uart channel buffer 
 *
 *  \param			msg		append character to the uart channel buffer
 *
 *  \param			msg_len		Message length
 *
 *  \return			None
 *
 **/

static void append_to_uart_console_message(unsigned uart_id, int mode, int msg_id, char ?msg[], int ?msg_len[])
{
	int len = 0;
	int buf_depth = uart_rx_channel_state[uart_id].buf_depth;

	if (0 == mode) 	//Copy message from message buffers
	{
		len = copy_console_message(uart_rx_channel_state[uart_id].channel_data[buf_depth], msg_id);
		uart_rx_channel_state[uart_id].buf_depth += len;
		uart_rx_channel_state[uart_id].write_index += len;
	}
	else if (1 == mode) 	//Append parameter data
	{
		string_copy(uart_rx_channel_state[uart_id].channel_data[buf_depth], msg[0], msg_len[0]);
		uart_rx_channel_state[uart_id].buf_depth += msg_len[0];
		uart_rx_channel_state[uart_id].write_index += msg_len[0];
	}
}

/** =========================================================================
 *  init_muart_server
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

//::Muart server
static void init_muart_server(streaming chanend c_tx_uart, streaming chanend c_rx_uart)
{
    int channel_id;
    int chnl_config_status = 0;
    char temp;
    for(channel_id = 0; channel_id < NUM_ACTIVE_UARTS; channel_id++)
    {
        chnl_config_status = configure_uart_channel(channel_id);
        if(0 != chnl_config_status)
        {
            printstr("Uart configuration failed for channel: "); //Displays if any of configuration is failed
            printintln(channel_id);
            chnl_config_status = 0;
        }
        else
        {
            printstr("Successful Uart configuration for channel: "); //Displays on Uart configuartion success
            printintln(channel_id);
        }
    } // for(channel_id = 0; channel_id < NUM_ACTIVE_UARTS; channel_id++)
    /* Release UART rx thread */
    do { c_rx_uart :> temp;} while (temp != MULTI_UART_GO); c_rx_uart <: 1; //Relase Threads from pause state
    /* Release UART tx thread */
    do { c_tx_uart :> temp;} while (temp != MULTI_UART_GO); c_tx_uart <: 1;
}
//::Muart end

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
//::Send Byte
void send_byte_to_uart_tx(s_uart_rx_channel_fifo &st)
{
    int buffer_space = 0;
    int data;

    if ((st.buf_depth > 0) && (st.buf_depth <= RX_CHANNEL_FIFO_LEN)) //Checks if there is any data available in teh buffers
    {
        read_byte_via_xc_ptr_indexed(data, st.channel_data, st.read_index);// REad byte and store it in data

        buffer_space = uart_tx_put_char(st.channel_id, (unsigned int)data); //push  byte to buffer_space
        if(-1 != buffer_space)
        {
            /* Data is pushed to uart successfully */
        	st.read_index++;
            if(st.read_index >= RX_CHANNEL_FIFO_LEN) {
            	st.read_index = 0;
            }
            st.buf_depth--;
        }
    }
}
//::Send Byte End

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
//::Reconfig Start
#pragma unsafe arrays
static int re_apply_uart_channel_config(unsigned channel_id,
                                        streaming chanend c_tx_uart,
                                        streaming chanend c_rx_uart)
{
    int chnl_config_status = 0;
    timer t;

    uart_tx_reconf_pause(c_tx_uart, t); //Pause the Uart tx core until reconfig is done
    uart_rx_reconf_pause(c_rx_uart); //Pause the Uart rx core until reconfig is done
    chnl_config_status = configure_uart_channel(channel_id); //configure uart channel with new baud rrate
    uart_tx_reconf_enable(c_tx_uart); //Enable the uart tx after reconfiguration
    uart_rx_reconf_enable(c_rx_uart);//Enable the uart rx after reconfiguration

    return chnl_config_status;
}
//::Reconfig End

/** =========================================================================
 *  push_byte_to_uart_rx_buffer
 *
 *  Pushes a byte to buffers based on channel ID
 *
 *  \param	s_uart_channel_config s		UartChannelConfig Reference to UART conf
 *
 *  \param	uart_char			Character to be pushed to the buffers
 *
 *  \return			None
 *
 **/

#pragma unsafe arrays
static void push_byte_to_uart_rx_buffer(s_uart_rx_channel_fifo &st, unsigned uart_char) //sends a byte to uart buffer
{
    if(st.buf_depth < RX_CHANNEL_FIFO_LEN)
    {
        write_byte_via_xc_ptr_indexed(st.channel_data, st.write_index, uart_char);
        st.write_index++;
        if(st.write_index >= RX_CHANNEL_FIFO_LEN)
        {
        	st.write_index = 0;
        }
        st.buf_depth++;
    }
    else
    {
#if ENABLE_XSCOPE == 1
        // Drop data due to buffer overflow
        printchar('!');
#endif
    }
  return;
}

/** =========================================================================
 *  validate_uart_baud
 *
 *  Checks if the baud rate is valid or not
 *
 *  \param	baud	Baud rate value
 *
 *  \return	1 	on success
 *
 **/

static int validate_uart_baud(int baud)
{
	for (int i=0; i<MAX_BAUD_RATE_INDEX; i++)
	{
		if (baud == valid_baud_rate[i]) //checks if input baud rate is valid or not
			return 1;
	}

	return 0;
}

/** =========================================================================
 *  validate_uart_cmd
 *
 *  Checks if file trannsfer is pending or not
 *
 *  \param	uart_cmd	uart pending file command
 *
 *  \param	uart_id		uart channel ID
 *
 *  \return	1 	on success
 *
 **/

static int validate_uart_cmd(char uart_cmd, unsigned uart_id)
{ //checks if file transfer is in progress or not
	if ((uart_comm_state[uart_id].pending_file_transfer) && ('p' != uart_cmd))
	{
		int len = 0;
		uart_comm_state[uart_id].pending_file_transfer = 0;
		send_message_to_uart_console(uart_id, IDX_FILE_DATA_LOST_MSG);
		uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_HELP;
		return 0;
	}
	else if ('p' != uart_cmd)
	{
		uart_rx_channel_state[uart_id].buf_depth = 0;
		uart_rx_channel_state[uart_id].read_index = 0;
		uart_rx_channel_state[uart_id].write_index = 0;
		return 1;
	}
	else
		return 1;
}

/** =========================================================================
 *  uart_state_handler
 *
 *  receives data from the uart channel based on channel ID and 
 *  does the operaion based on input command
 *
 *  \param	uart_id		uart channel ID
 *
 *  \param	uart_char	received character from Uart pins
 *
 *  \param	c_tx_uart	channel to send uart data
 *
 *  \param	c_rx_uart	channel to receive uart data
 *
 *  \return	1 	on success
 *
 **/

static void uart_state_hanlder(unsigned uart_id, unsigned uart_char,
        streaming chanend c_tx_uart,
        streaming chanend c_rx_uart)
{
	static int iter_index = 0;

	if (0 == uart_comm_state[0].welcome_msg_sent) //sends welcome message on start up
	{
		uart_comm_state[uart_id].welcome_msg_sent = 1;
		send_message_to_uart_console(uart_id, IDX_WELCOME_USAGE); //send welcome message to terminal
		return;
	}

	if (0x1b == uart_char) //'ESC' char is received
	{
		uart_comm_state[uart_id].uart_mode = UART_MODE_CMD;
		if (UART_MODE_CMD == uart_comm_state[uart_id].uart_mode) //Checks if uart mode is command or data
			send_message_to_uart_console(uart_id, IDX_CMD_MODE_MSG); //Command Mode
		else
			send_message_to_uart_console(uart_id, IDX_DATA_MODE_MSG); //Data Mode
		return;
	}
	if (UART_MODE_CMD == uart_comm_state[uart_id].uart_mode) //Command Mode Selected
	{
		if (validate_uart_cmd(uart_char, uart_id))
		{
			switch (uart_char)
			{
				case 'e': //Echo data mode is selected
					uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_DATA;
					send_message_to_uart_console(uart_id, IDX_ECHO_MODE_MSG);
					uart_comm_state[uart_id].uart_mode = UART_MODE_DATA;
					break;

				case 'h': //Help option mode is selecetd
					uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_HELP;
					send_message_to_uart_console(uart_id, IDX_USAGE_HELP);
					break;

				case 'r': //Reconfigure baud rate for uart
					uart_comm_state[uart_id].uart_usage_mode = UART_CMD_UART_RECONF;
					send_message_to_uart_console(uart_id, IDX_RECONF_MODE_MSG);
					uart_comm_state[uart_id].uart_mode = UART_MODE_DATA;
					break;

				case 'b': //Pipe option mode is selected
				{

					num_chr_received=0;
					for(int i=0; i<NUM_ACTIVE_UARTS;i++)
					{
						if(i == 0) //Uart channel 0 will be in recived data mdoe
							uart_comm_state[i].uart_usage_mode = UART_CMD_PIPE_FILE_RCV;
						else //Rest of the channels will be in idle state
							uart_comm_state[i].uart_usage_mode = UART_CMD_PIPE_FILE_IDLE;
						uart_comm_state[i].uart_mode = UART_MODE_DATA;
					}
				}
					break;

				default:
					uart_comm_state[uart_id].uart_usage_mode = UART_CMD_INVALID;
					send_message_to_uart_console(uart_id, IDX_INVALID_USAGE);
					break;
			} //End of Switch
			iter_index = 0;
		}
		return;
	} //Command Mode end

	switch (uart_comm_state[uart_id].uart_usage_mode) //Uart Usage Modes
	{
		case UART_CMD_ECHO_DATA: //Data received is sent back on same channel
			push_byte_to_uart_rx_buffer(uart_rx_channel_state[uart_id], uart_char);
			break;

		case UART_CMD_UART_RECONF: //Change Baud Rate settings
		{
			static char baud[10] = "";

			if ((iter_index < 10) && (0xd != uart_char))
			{
				baud[iter_index] = uart_char; //Moves the input Baud Rate value to buffer
				iter_index++;
			}
			else if ((iter_index < 10) && (0xd == uart_char))  //'Carriage Return' is received
			{
				int user_baud = 0;

				baud[iter_index] = '\0';
				user_baud = atoi(baud);
				printstr("Input Baud Rate is :");
				printintln(user_baud);
				if (validate_uart_baud(user_baud)) //Checks if Input baud rate is supported or not
				{
					printstrln("Baud Rate setting Succesful !!");
					uart_channel_config[uart_id].baud = user_baud; //Changes the New Baud Rate
					re_apply_uart_channel_config(uart_id, c_tx_uart, c_rx_uart); //Applies the New baud rate to uart channels
					uart_comm_state[uart_id].uart_mode = UART_MODE_CMD;
				}
				else
				{
					printstrln("Invalid Baud Rate");
					send_message_to_uart_console(uart_id, IDX_RECONF_FAIL_MSG);// send baud rate fail message
				}
				iter_index = 0;
			}
			else
				iter_index = 0;
		}
			break;

		case UART_CMD_PUT_FILE: //Sends file with timing information
			if (0 == uart_rx_channel_state[uart_id].buf_depth)
			{
				uart_comm_state[uart_id].pending_file_transfer = 0;
				uart_comm_state[uart_id].uart_mode = UART_MODE_CMD;
			}
			break;

		case UART_CMD_PIPE_FILE_RCV: // Pipes the data through all Uart channels
		{
			if(uart_char == 0x04) //Waits until ESC character is received
			{
				Char_length=-1;
				INITIAL=1;
				Channel_ID=1;
				for(int i=0; i<NUM_ACTIVE_UARTS;i++)
				{
					if(i == 0)
					{

						uart_comm_state[i].uart_usage_mode = UART_CMD_PIPE_FILE_IDLE; //Makes uart channel 0 to idle state
					}
					else
						uart_comm_state[i].uart_usage_mode = UART_CMD_PIPE_FILE; //Pipe file theough all channel state
					uart_comm_state[i].uart_mode = UART_MODE_DATA;
				}
				tmr :> time_start;
			}
			Char_length++;
			push_byte_to_uart_rx_buffer(uart_rx_channel_state[1], uart_char); //Pushes the byte to uart buffer
			num_chr_received++;

				/* Receive file, pipe it to all channels and validate it */
				/* time the transfer */
		}
				break;
		case UART_CMD_PIPE_FILE:
			if((uart_id != NUM_ACTIVE_UARTS-1 ) && (uart_id != 0)) //checks if uart channel is not 0 or last channel
				push_byte_to_uart_rx_buffer(uart_rx_channel_state[uart_id+1], uart_char);// sends the character to uart buffer
			else if(uart_id == (NUM_ACTIVE_UARTS-1))
			{
				if(INITIAL)
				{
					uart_rx_channel_state[0].buf_depth=0;
					uart_rx_channel_state[0].read_index=0;
					uart_rx_channel_state[0].write_index=0;
					INITIAL=0;
				}
				push_byte_to_uart_rx_buffer(uart_rx_channel_state[0], uart_char);
			}
			break;
		default:
			/* Ignore the received data */
			break;
	}
}

/** =========================================================================
 *  uart_tx_handler
 *
 *  Transmit buffer data on to uart tx pins
 *  
 *
 *  \param	uart_id		uart channel ID
 *
 *  \return	none
 *
 **/

static void uart_tx_hanlder(unsigned uart_id)
{
	switch (uart_comm_state[uart_id].uart_usage_mode) {
	case UART_CMD_INVALID: //send data availabe in uart buffers to uart tx pins
	case UART_CMD_ECHO_DATA:
	case UART_CMD_UART_RECONF:
	case UART_CMD_ECHO_HELP:
		send_byte_to_uart_tx(uart_rx_channel_state[uart_id]); //send data to uart tx pins
		break;

	case UART_CMD_PIPE_FILE: //pipe file through all channels
	{
		timer tmr;
		unsigned int ts;
		if(Channel_ID == uart_id) //checks if uart id is same as channels ID
		{

			if(uart_rx_channel_state[uart_id].buf_depth == 0)
				Channel_ID++;
			if(Channel_ID == NUM_ACTIVE_UARTS)
			{
				Channel_ID=0;
				uart_comm_state[0].uart_usage_mode = UART_CMD_PUT_FILE; //If data is on last Uart then Channel 0 is set to Put file state
			}
			if(uart_id == 0)
			{
				if(uart_rx_channel_state[uart_id].buf_depth == 0) //checks if there is data in teh uart buffer
				{
						uart_comm_state[0].uart_usage_mode = UART_CMD_PUT_FILE;
				}
			}
			send_byte_to_uart_tx(uart_rx_channel_state[uart_id]); //send byte to Tx pins
		}
	}
		break;

	case UART_CMD_PUT_FILE: //moves the content of buffer on to the TX pins
		if(0 != uart_rx_channel_state[uart_id].buf_depth) //checks if buffer is empty or not initially
		{
			while(0 != uart_rx_channel_state[uart_id].buf_depth)
			{
				send_byte_to_uart_tx(uart_rx_channel_state[uart_id]); //transmits all the data to TX until buffer is empty
			}
		if (0 == uart_rx_channel_state[uart_id].buf_depth) //If buffer is empty, then appends timing inforamtion
		{
			uart_comm_state[uart_id].uart_mode = UART_MODE_CMD;
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_HELP;// after displaying the timing inforamtion Uart goes to echo help mode
		}
		}
		else
		{
			uart_comm_state[uart_id].uart_mode = UART_MODE_CMD;
			uart_comm_state[uart_id].uart_usage_mode = UART_CMD_ECHO_HELP;
			send_message_to_uart_console(uart_id, IDX_PIPE_BROKEN);
		}
		break;
	}
}

/** 
 *  The multi uart manager thread. This thread
 *  initiliazes MUART server and data structures maintained by
 *  application handler, waits for UART data received from
 *  MUART Rx thread and processes, and transmits processed
 *  application data to MUART Tx thread
 *
 *  \param	chanend cWbSvr2AppMgr channel end sharing web server thread
 *  \param	chanend c_tx_uart		channel end sharing channel to MUART TX thrd
 *  \param	chanend c_rx_uart		channel end sharing channel to MUART RX thrd
 *  \return	None
 *
 */
void uart_manager(streaming chanend c_tx_uart, streaming chanend c_rx_uart)
{
    char rx_channel_id;
    unsigned int uart_id = 0;
    timer timer_event;
    unsigned time;
#if ENABLE_XSCOPE == 1
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC);
#endif

    init_uart_parameters();
    init_muart_server( c_tx_uart, c_rx_uart);
    timer_event:>time;
    // Loop forever processing Tx and Rx UART data
//::Receive Data
    while(1)
    {
        select
        {
#pragma ordered
            case c_rx_uart :> rx_channel_id:
            {
                unsigned uart_char;

                uart_char = (unsigned)uart_rx_grab_char(rx_channel_id);
                if(uart_rx_validate_char(rx_channel_id, uart_char) == 0)
                {
                	uart_state_hanlder(rx_channel_id, uart_char, c_tx_uart, c_rx_uart);
                }
                break;
            }
//::Receive Data End
            case timer_event when timerafter (time+DELAY_CHAR_SEND):> time:
            	uart_tx_hanlder(uart_id);
            	uart_id++;
                if (uart_id >= NUM_ACTIVE_UARTS)
                	uart_id = 0;

                break;
        } // select
    } // while(1)
}

