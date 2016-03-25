//
//  net_tvos.c
//  Quake
//
//  Created by Heriberto Delgado on 3/25/16.
//
//

#include "quakedef.h"

#include "net_loop.h"

net_driver_t net_drivers[MAX_NET_DRIVERS] =
{
    {
        "Loopback",
        false,
        Loop_Init,
        Loop_Listen,
        Loop_SearchForHosts,
        Loop_Connect,
        Loop_CheckNewConnections,
        Loop_GetMessage,
        Loop_SendMessage,
        Loop_SendUnreliableMessage,
        Loop_CanSendMessage,
        Loop_CanSendUnreliableMessage,
        Loop_Close,
        Loop_Shutdown
    }
};
int net_numdrivers = 1;

net_landriver_t	net_landrivers[MAX_NET_DRIVERS];
int net_numlandrivers = 0;
