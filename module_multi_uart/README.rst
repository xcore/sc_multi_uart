Multi-UART Module
=================

:scope: General Use
:description: Octuple UART in two logical cores
:keywords: UART
:boards: XA-SK-UART-8

This module provides an efficient implementation of multiple UARTs, up to 8 uarts with RX and TX drivers in two cores. The uarts use 8 bit ports, thus leaving critical 1 bit port resources free for other uses.

Features
--------

   * Up to 8 uarts running up to 115.2KBaud
   * Uses two 8-bit ports for 8 uarts
   * Supports variable settings for stop bits, parity, baud rate and bits per character
   * Dynamic reconfiguration of all key parameters
