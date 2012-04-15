/*
//Very much silly wandering script distance limited

//Copyright 2011 H4n Marquis

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

//Very much silly, but smooth, wandering script
*/

/*
Script Parameters
Enjoy to change them
seeing what changes in the run...
*/
//debug yes = TRUE
//no = FALSE
integer iDebugScript = TRUE;
//minimum height
float minZ = 21.5;
//maximum height
float maxZ = 50.0;
//maximum distance
//from the starting point
float fMaxDist = 50.0;
//max time pause
float maxPause = 30.0;
//min time pause
float minPause = 10.0;
//max size of every x move
float moveX = 5.0;
//max size of every y move
float moveY = 5.0;
//max size of every z move
float moveZ = 1.0;
//number of steps
float stepsNum = 20.0;

/*
Script Globals
*/
//The starting point,
//the script sets it
//everytime the object starts
//to wander.
vector vecStartPoint;

/*
Script Functions
*/

vector getNewRandomVector(float mX, float mY, float mZ)
{
    vector vectRet = <(llFrand(mX)-(mX/2.0)),(llFrand(mY)-(mY/2.0)),(llFrand(mZ)-(mZ/2.0))>;
    
    return vectRet;
}

vector getHome(vector vecStartingPos, float minimumZ, float maximumZ)
{
    vector vecRet = vecStartingPos;
    
    if((minimumZ > 0) && (maximumZ > 0))
    {
        vecRet.z = (maximumZ + minimumZ)/2;
    }
    
    return vecRet;
}

integer checkTarget(vector vecStartingPos, vector vecTarget, float minimumZ, float maximumZ, float fMaximumDist)
{
    integer iRet = FALSE;
    vector vecAux;
    
    if((minimumZ > 0) && (maximumZ > 0))
    {
        if((vecTarget.z >= minimumZ) && (vecTarget.z <= maximumZ)){
            if(fMaximumDist > 0)
            {
                //If vecTartget.z is already between minimumZ and maximumZ
                //I have to check only the x and y axes distance
                vecAux.x = vecStartingPos.x;
                vecAux.y = vecStartingPos.y;
                vecAux.z = vecTarget.z;
                if(llVecDist(vecTarget, vecAux) <= fMaximumDist)
                {
                    iRet = TRUE;
                }
            }
            else
            {
                //vecTartget.z is already between minimumZ and maximumZ
                //and the script has to ignore maximum distance from
                //the starting point
                iRet = TRUE;
            }
        }
    }
    else if(fMaximumDist > 0)
    {
        //minimumZ and maximumZ are both not positive then the
        //script has to ignore them and fMaximumDist is positive
        //then the script has to check only distance.
        if(llVecDist(vecTarget, vecStartingPos) <= fMaximumDist)
        {
            iRet = TRUE;
        }
    }
    else
    {
        //minimumZ, maximumZ and fMaximumDist are all not positive
        //then no limit at all
        iRet = TRUE;
    }
    
    return iRet;
}

integer moveToTarget(vector vecTarget, float steps, integer debug)
{
    integer iRet = FALSE;
    vector vecPresentPos = llGetPos();
    vector vecTotalDelta = vecTarget - vecPresentPos;
    integer tenths = (llFloor(llVecDist(vecTarget, vecPresentPos)/10.0))+1;
    float times = ((float)tenths)*steps;
    vector vecStepVec = vecTotalDelta/times;
    vector singleStepTarget = vecPresentPos;
    float i = 0.0;
    
    if(debug)
    {
        llOwnerSay("On my way toward " + (string)vecTarget);
    }
    for(i = 1.0; i < times; i = i + 1.0)
    {
        singleStepTarget = singleStepTarget + vecStepVec;
        llStopLookAt();
        llLookAt(singleStepTarget, 1.0, 1.0);
        llSetPos(singleStepTarget);
    }
    llStopLookAt();
    llLookAt(vecTarget, 1.0, 1.0);
    llSetPos(vecTarget);
    
    iRet = TRUE;
    
    return iRet;
}

/*
Script states
*/

default
{
    state_entry()
    {
        llSetStatus(STATUS_PHANTOM,TRUE);
        llSetTimerEvent(0.0);
        llSetTouchText("Wander");
        llOwnerSay("Waiting for your touch...");
    }
    on_rez(integer start_param)
    {
        llResetScript();
    }
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            llResetScript();
        }
    }
    touch_start(integer num_detected)
    {
        key owner = llGetOwner();
        
        if (llDetectedKey(0) == owner)
        {
            state wandering;
        }
        else
        {
            llInstantMessage(owner, "Key = \"" + llDetectedKey(0) + "\",\"" + llDetectedName(0) + "\" has just touched me!!!");
        }
    }
}

state wandering
{
    state_entry()
    {
        llSetTouchText("Stop!");
        llOwnerSay("Starting to wander around. Touch me again if you want to stop me.");
        llSetStatus(STATUS_PHANTOM,TRUE);
        vecStartPoint = llGetPos();
        llSetTimerEvent(0.1);
    }
    timer()
    {
        float pause = llFrand((maxPause-minPause))+minPause;
        vector vecTotalDelta = getNewRandomVector(moveX, moveY, moveZ);
        vector vecFinalTarget = llGetPos() + vecTotalDelta;
        
        llSetTimerEvent(0.0);
        if(!checkTarget(vecStartPoint, vecFinalTarget, minZ, maxZ, fMaxDist))
        {
            state homing;
        }
        if(moveToTarget(vecFinalTarget, stepsNum, iDebugScript))
        {
            if(iDebugScript)
            {
                llOwnerSay((string)vecFinalTarget + " reached.");
            }
        }
        if(iDebugScript)
        {
            llOwnerSay("Pausing for " + (string)pause + " secs");
        }
        llSetTimerEvent(pause);
    }
    on_rez(integer start_param)
    {
        llResetScript();
    }
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            llResetScript();
        }
    }
    touch_start(integer num_detected)
    {
        key owner = llGetOwner();
         
        if (llDetectedKey(0) == owner)
        {
            state default;
        }
        else
        {
            llInstantMessage(owner, "Key = \"" + llDetectedKey(0) + "\",\"" + llDetectedName(0) + "\" has just touched me!!!");
        }
    }
}

state homing
{
    state_entry()
    {
        vector vecHome = getHome(vecStartPoint, minZ, maxZ);
        llSetTimerEvent(0.0);
        llSetStatus(STATUS_PHANTOM,TRUE);
        if(iDebugScript)
        {
            llOwnerSay("Homing toward " + (string)vecHome);
        }
        if(moveToTarget(vecHome, stepsNum, iDebugScript))
        {
            if(iDebugScript)
            {
                llOwnerSay((string)vecHome + " reached. (Home reached, going back to wandering)");
            }
            state wandering;
        }
        
    }
    on_rez(integer start_param)
    {
        llResetScript();
    }
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)         
        {
            llResetScript();
        }
    }
}
