/*
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
//minimum height
float minZ = 21.0;
//maximum height
float maxZ = 50.0;
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
Script Functions
*/

vector getNewRandomVector(float mX, float mY, float mZ)
{
    vector vectRet = <(llFrand(mX)-(mX/2.0)),(llFrand(mY)-(mY/2.0)),(llFrand(mZ)-(mZ/2.0))>;
    
    return vectRet;
}

move(vector startingPos, float mX, float mY, float mZ, float minimumZ, float maximumZ)
{
    vector totalDelta = getNewRandomVector(mX, mY, mZ);
    vector finalTarget = startingPos + totalDelta;
    vector singleStepVec = totalDelta/stepsNum;
    vector singleStepTarget = startingPos;
    float i;
    
    llOwnerSay("On my way toward " + (string)finalTarget);
    //I wish to iterate (stepsNum - 1) times
    for(i = 1.0; i < stepsNum; i = i + 1.0)
    {
        singleStepTarget = singleStepTarget + singleStepVec;
        if((singleStepTarget.z < minimumZ) || (singleStepTarget.z > maximumZ)){
            singleStepTarget.z = (maximumZ + minimumZ)/2;
        }
        llStopLookAt();
        llLookAt(singleStepTarget, 1.0, 1.0);
        llSetPos(singleStepTarget);
    }
    //last move
    singleStepTarget = startingPos + totalDelta;
    if((finalTarget.z < minimumZ) || (finalTarget.z > maximumZ)){
        finalTarget.z = (maximumZ + minimumZ)/2;
    }
    llStopLookAt();
    llLookAt(finalTarget, 1.0, 1.0);
    llSetPos(finalTarget);
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
        llSetTimerEvent(0.1);
    }
    timer()
    {
        float pause = llFrand((maxPause-minPause))+minPause;
        
        llSetTimerEvent(0.0);
        move(llGetPos(), moveX, moveY, moveZ, minZ, maxZ);
        llOwnerSay("Pausing for " + (string)pause + " secs");
        llSetTimerEvent(pause);
    }
    on_rez(integer start_param)
    {
        llResetScript();
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