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

//Very much silly wandering script
*/

//minimum height
float minZ = 21.0;
//maximum height
float maxZ = 50.0;

default
{
    state_entry()
    {
        llOwnerSay("Script running");
        llSetStatus(STATUS_PHANTOM,TRUE);
        llSetTimerEvent(5);
    }
    timer()
    {
        vector curPos = llGetPos();
        vector randAdj = <(llFrand(4.0)-2.0),(llFrand(4.0)-2.0),(llFrand(2.0)-1.0)>;
        vector newTarget = curPos + randAdj;
        if((newTarget.z < minZ) || (newTarget.z > maxZ)){
            newTarget.z = (maxZ + minZ)/2;
        }
        llOwnerSay("Moving to new target = " + (string)newTarget);
        llStopLookAt();
        llLookAt(newTarget, 1.0, 1.0);
        llSetPos(newTarget);
    }
}
