; AVI Joiner
;
; AutoHotkey Version: 1.0.48.05 (tested version)
; Language:       English
; Platform:       Windows XP SP3 (tested version)
; Author:         Copyright 2010 Bob Menke
; Author Contact: bobbo33 on http://productivegeek.com/forums/forum/lifehacker-coders
;
; Script Function:
;    Allows user to select and organize a list of AVI files.
;    Runs mencoder to join these AVI files into one file.
;
;    code credit for list manipulation functions:
;        http://www.autohotkey.com/forum/topic3240.html
;
;-------------------------------------------------------------------------
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;-------------------------------------------------------------------------
;
; Change log:
; v0.1 2010-01-23 First prototype
; v0.2 2010-01-24 Add GuiDropFiles to enable drag-n-drop
;                 Bug fixes for deleting/clearing last item in list
;                 Error checking in RunJoiner for missing mencoder.exe, input files
;                 Added AppVersionString, AppHyperlink variables for easier updates
;                 Added pause at end of Mencoder.exe run (give user chance to view results)
;                 General commenting cleanup
;-------------------------------------------------------------------------

;general AHK setup
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;global variables
AllowedExtList = avi
ExcludedExtList = tmp
AppWinTitle = AVI Joiner
AppVersionString = v0.2 (2010-01-24)
AppHyperlink = http://productivegeek.com/forums/forum/lifehacker-coders
TargetList = 1
TargetListOSD = %TargetList%
BlankVar =

;create GUI
Gui, Add, Button, gAddFile x6 y10 w100 h30, Add File
Gui, Add, Button, gRemoveItem x6 y40 w100 h30, Remove Item
Gui, Add, Button, gRemoveAll x6 y70 w100 h30, Remove All
Gui, Add, Button, gMoveItemUp x6 y100 w100 h30, Move Item Up
Gui, Add, Button, gMoveItemDown x6 y130 w100 h30, Move Item Down
Gui, Add, Button, gRunJoiner x6 y190 w100 h30, RUN AVI JOINER!

Gui, Add, Text, gTargetList1 x136 y10 w450 h20, Files to be joined (Note: bitrate/resolution/codec must match!)
Gui, Add, ListBox, gTargetList1 vListBox1 AltSubmit HScroll x136 y30 w450 h315,
Gui, Add, Text, x25 y355 w265 h20, %AppWinTitle% %AppVersionString%.     For latest version, see:
Gui,Font,CBlue Underline
Gui, Add, Text, gLifehackerCoders x290 y355 w300 h20, %AppHyperlink%
Gui,Font

;run GUI
Gui, Show, x0 y0 h377 w594, %AppWinTitle%
Return

;------------------------------------------------------------
GuiClose:
;function executes when GUI is closed by user
ExitApp
;------------------------------------------------------------
TargetList1:
;selects Listbox1 as active list box for various list functions
TargetList = 1
OtherList = 2
GuiControl,1:,TargetListOSD, 1
Return
;------------------------------------------------------------
AddFile:
;adds a file to the active listbox
FileSelectFile, FilesToAdd, M 3,, Select some files, Video Files (*.avi)
If FilesToAdd =
   Return
Loop, parse, FilesToAdd, `n
{
   If A_Index = 1
      RootPath = %A_LoopField%
   Else
   {
      StringSplit, FileListArray, A_loopField, `.
      If FileListArray%FileListArray0% Not Contains %AllowedExtList%
         Continue
      If FileListArray%FileListArray0% In %ExcludedExtList%
         Continue
      Else
      {
         If ListBoxCont%TargetList% =
         {
            ListBoxCont%TargetList% = %RootPath%\%A_LoopField%
         }
         Else ;If ListBoxCont%TargetList% <>
         {
             ListBoxCont%TargetList% := ListBoxCont%TargetList% . "|" . RootPath . "\" . A_LoopField
         }
      }
   }
}
GoSub, SplitUpString
GoSub, FillListFromArray
Return
;------------------------------------------------------------
RemoveItem:
;removes the selected item from the active listbox
Gui, Submit, NoHide
ItemToRemovePos := ListBox%TargetList%
;v0.2 fixed bug when attempting to remove, but nothing selected
If StrLen(ItemToRemovePos)<1
	Return
;Create array of listboxes contents
GoSub, SplitUpString
;Remove Selected Item
GoSub, RemoveSelection
;Recreate array with new list after selected item was removed
GoSub, SplitUpString
;Fill array and update listbox
GoSub, FillListFromArray
Control, Choose, %ItemToRemovePos%, ListBox%TargetList%, %AppWinTitle%

;This method below is a complex version that removes the selected item from the list
;however this does NOT remove that selected item from the array that makes up that list

;GuiControl, -AltSubmit, ListBox%TargetList%
;GuiControlGet, FileList,, ListBox%TargetList%
;ControlGet, ItemToRemove, FindString, %FileList%, ListBox%TargetList%, %AppWinTitle%
;Control, Delete, %ItemToRemove%, ListBox%TargetList%, %AppWinTitle%
;GuiControl, Choose, ListBox%TargetList%, %ItemToRemove%
;GuiControl, +AltSubmit, ListBox%TargetList%
Return
;------------------------------------------------------------
MoveItemDown:
;moves the selected item down one row in the active listbox
Gui, Submit, NoHide
GoSub, SplitUpString
 
; If selected entry is not first entry
If (ListBox%TargetList% < ArrayOfAllEntries0)
{
   ; New position is one up
   NewPosition := ListBox%TargetList% + 1
   
   ; Flip entries
   GoSub, FlipEntriesInArray
   
   ; Fill Array into Listbox
   GoSub, FillListFromArray
        
   ; Keep moved entry selected
   GuiControl, Choose, ListBox%TargetList%, %NewPosition%
}
Return
;------------------------------------------------------------
MoveItemUp:
;moves the selected item up one row in the active listbox
BtnMoveItemUp:
Gui, Submit, NoHide
GoSub, SplitUpString
 
; If selected entry is not first entry
If (ListBox%TargetList% > 1)
{
   ; New position is one up
   NewPosition := ListBox%TargetList% - 1
   
   ; Flip entries
   GoSub, FlipEntriesInArray
   
   ; Fill Array into Listbox
   GoSub, FillListFromArray
        
   ; Keep moved entry selected
   GuiControl, Choose, ListBox%TargetList%, %NewPosition%
}
Return
;------------------------------------------------------------
FlipEntriesInArray: 
;swaps the position of two items in the active listbox

PosValue := ListBox%TargetList%
; Get selected entry from Array
CurrentEntry := ArrayOfAllEntries%PosValue% ;%LstToDo%

; Put entry from new position in Array into current position
ArrayOfAllEntries%PosValue% := ArrayOfAllEntries%NewPosition%

; Put selected entry into new position in Array
ArrayOfAllEntries%NewPosition% = %CurrentEntry%
Return
;-------------------------------------------------------------
SplitUpString:
;preps the listbox contents string to be loaded into the active listbox
SplitVar := ListBoxCont%TargetList%
StringSplit, ArrayOfAllEntries, SplitVar, |
Return
;------------------------------------------------------------
FillListFromArray:
; Build string from array and assign it to the listbox control
FillString =
Loop, %ArrayOfAllEntries0%
{
   Entry := ArrayOfAllEntries%A_Index%
   FillString = %FillString%|%Entry%
}
;v0.2 fix not clearing control if ArrayOfAllEntries0 is zero (no contents)
If StrLen(FillString)<1
    GuiControl,1:, ListBox%TargetList%, |
Else	
    GuiControl,1:, ListBox%TargetList%, %FillString%
StringTrimLeft, FillString, FillString, 1
ListBoxCont%TargetList% = %FillString%
Return
;--------------------------------------------------------------
RemoveSelection:
;removes the selected item from the active listbox
ItemToRemove := ArrayOfAllEntries%ItemToRemovePos%
If ItemToRemovePos = 1
{
   StringReplace, ListBoxCont%TargetList%, ListBoxCont%TargetList%, %ItemToRemove%|
}
If ItemToRemovePos <> 1
{
   StringReplace, ListBoxCont%TargetList%, ListBoxCont%TargetList%, |%ItemToRemove%
}
;Used to remove selected item if its the only item remaining in a list
If ArrayOfAllEntries0 <= 1
{
   StringReplace, ListBoxCont%TargetList%, ListBoxCont%TargetList%, %ItemToRemove%
}
Return
;------------------------------------------------------------
GuiDropFiles:
;v0.2 added this function to enable drag-n-drop of files from Windows Explorer
Loop, parse, A_GuiControlEvent, `n
{
   StringSplit, FileListArray, A_loopField, `.
   
   If FileListArray%FileListArray0% Not In %AllowedExtList%
      Continue
   Else If FileListArray%FileListArray0% In %ExcludedExtList%
      Continue
   Else
   {
      ;GuiControl,1:, ListBox%TargetList%, %RootPath%\%A_LoopField%
      If ListBoxCont%TargetList% =
      {
         ListBoxCont%TargetList% = %A_LoopField%
      }
      Else ;If ListBoxCont%TargetList% <>
      {
         ListBoxCont%TargetList% := ListBoxCont%TargetList% . "|" . A_LoopField
      }
   }
}
GoSub, SplitUpString
GoSub, FillListFromArray
Return
;--------------------------------------------------------------
RemoveAll:
;removes all items from the active listbox
ListBoxCont%TargetList% := ""
GoSub, SplitUpString
GoSub, FillListFromArray
Return
;--------------------------------------------------------------
RunJoiner:
;prompts user for output file name, the uses mencoder.exe to to join the selected input files
;code credit: http://www.misterhowto.com/index.php?category=Computers&subcategory=Video&article=join_with_mencoder
;where to find mencoder.exe: http://www.mplayerhq.hu/design7/dload.html
IfNotExist mencoder.exe
{
   MsgBox, 16, Installation Error, 'Mencoder.exe' not found.`n`nMake sure this files exists in the same directory as this program.
   Return
}
If (StrLen(ArrayOfAllEntries0)<1 Or ArrayOfAllEntries0<2)
{
   MsgBox, 16, File Selection Error, Please select at least 2 valid AVI files before proceeding. 
   Return
}
FileSelectFile, OutputFile, S 16,, Select output file name, Video Files (*.avi)
If OutputFile =
   Return
StringReplace, InputFiles, ListBoxCont%TargetList%, |, "%A_SPACE%", All
CmdLine = cmd /c mencoder.exe -oac copy -ovc copy -idx -o "%OutputFile%" "%InputFiles%" && echo. && pause
If StrLen(CmdLine)>8191
{
   MsgBox, 16, Command Error, The mencoder.exe command length is too long.`n`nPlease select less files and try again.
   Return
}
RunWait, cmd /c mencoder.exe -oac copy -ovc copy -idx -o "%OutputFile%" "%InputFiles%" && echo. && pause
Return
;--------------------------------------------------------------
LifehackerCoders:
;user hyperlink back to the program's home
Run,%AppHyperlink%,,UseErrorLevel
Return

;debug
F9::Reload
F10::ListVars
