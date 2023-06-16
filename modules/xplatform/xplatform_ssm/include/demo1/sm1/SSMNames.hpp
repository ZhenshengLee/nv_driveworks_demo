/////////////////////////////////////////////////////////////////////////////////////////
//
// Notice
// ALL NVIDIA DESIGN SPECIFICATIONS AND CODE ("MATERIALS") ARE PROVIDED "AS IS" NVIDIA MAKES
// NO REPRESENTATIONS, WARRANTIES, EXPRESSED, IMPLIED, STATUTORY, OR OTHERWISE WITH RESPECT TO
// THE MATERIALS, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES OF NONINFRINGEMENT,
// MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.
//
// NVIDIA CORPORATION & AFFILIATES assumes no responsibility for the consequences of use of such
// information or for any infringement of patents or other rights of third parties that may
// result from its use. No license is granted by implication or otherwise under any patent
// or patent rights of NVIDIA CORPORATION & AFFILIATES. No third party distribution is allowed unless
// expressly authorized by NVIDIA. Details are subject to change without notice.
// This code supersedes and replaces all information previously supplied.
// NVIDIA CORPORATION & AFFILIATES products are not authorized for use as critical
// components in life support devices or systems without express written approval of
// NVIDIA CORPORATION & AFFILIATES.
//
// SPDX-FileCopyrightText: Copyright (c) 2016-2021 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
// SPDX-License-Identifier: LicenseRef-NvidiaProprietary
//
// NVIDIA CORPORATION, its affiliates and licensors retain all intellectual
// property and proprietary rights in and to this material, related
// documentation and any modifications thereto. Any use, reproduction,
// disclosure or distribution of this material and related documentation
// without an express license agreement from NVIDIA CORPORATION or
// its affiliates is strictly prohibited.
//
// Parser Version: 0.7.5
// SSM Version:    0.9.1
//
/////////////////////////////////////////////////////////////////////////////////////////

/**
* The following file has been generated by SSM's parser.
* Please do not manually modify the files
*/


#pragma once

#include <stdint.h>
#include <map>
#define FixedMap std::map

#define MAX_DATA_TYPE_SIZE              50

namespace SystemStateManager
{


/// Labels for SSM
#define SSM_SSM_str "SSM"
#define SSM_SSM_Standby_str "Standby"
#define SSM_SSM_NormalOperation_str "NormalOperation"
#define SSM_SSM_Degrade_str "Degrade"
#define SSM_SSM_UrgentOperation_str "UrgentOperation"
#define SSM_SSM_STATES_COUNT 4

//Number of State Machines
#define SSM_SM1_SM_COUNT 1

namespace SM1
{

enum class StateMachines;
typedef FixedMap<std::string, StateMachines> StateMachineStrEnumMap;

enum class LockSteppedCommands : int {
    MAX_CMD = 0,
};

enum class StateMachines : int
{
    INVALID_STATEMACHINE,
    SSM,
};

enum class SSMStates : int
{
    NULL_STATE,
    Degrade,
    NormalOperation,
    Standby,
    UrgentOperation,
};

typedef struct _userDataPkt {
    char dataType[MAX_DATA_TYPE_SIZE];
    uint64_t timestamp;
    StateMachines targetStateMachine;
    StateMachines sourceStateMachine;
    int size;
    char data[2048]; //2048 is the Maximum Data Size
} UserDataPkt;

}

}