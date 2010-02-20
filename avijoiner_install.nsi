# AVI Joiner Installer
#
# NSIS Version:   2.46
# Language:       English
# Platform:       Windows XP SP2 (tested version)
# Author:         Copyright 2010 Thomas Bass
# Author Contact: t0mt0m on http://productivegeek.com/forums/forum/lifehacker-coders
#
# Script Function:
#    NSIS Installer script for an windows installation of the
#    program "avi_joiner.exe"
#
#-------------------------------------------------------------------------
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------
#
# Change log:
# v0.0.1 2010-01-23 - tbass - first prototype
# v0.0.2 2010-01-30 - tbass - added latest version of avi_joiner.exe
#							- added readme.txt file
#							- added GPL v3 license file
#							- removed mencoder distribution related TODOs

# TODO: insert program in windows "add/remove programs"
# TODO: create a portable installation
# TODO: validate uninstall directory
# TODO: as long as no stable version of avi_joiner is released, add a
#       warning page to the installer
# TODO: multilanguage installer (translators needed!)
# TODO: add detailed version information to installer exe
# TODO: 
!define VERSION "0.0.2"

# name of the installer executable
Name "Avi-Joiner ${VERSION}"
XPStyle on
CRCCheck force

outFile "avijoiner_setup.exe"
InstallDir $PROGRAMFILES\avijoiner

PageEx license
	LicenseData licdata.txt
	LicenseForceSelection checkbox
PageExEnd

Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Section "Installer Section"

SetOutPath $INSTDIR

file mencoder.exe
file avi_joiner.exe
file readme.txt
file license.txt

writeUninstaller $INSTDIR\uninstaller.exe

CreateDirectory "$SMPROGRAMS\AVI Joiner"
createShortCut "$SMPROGRAMS\AVI Joiner\avi_joiner.lnk" "$INSTDIR\avi_joiner.exe"
createShortCut "$SMPROGRAMS\AVI Joiner\uninstall.lnk" "$INSTDIR\uninstaller.exe"
createShortCut "$SMPROGRAMS\AVI Joiner\readme.lnk" "$INSTDIR\readme.txt"
createShortCut "$SMPROGRAMS\AVI Joiner\GPL license v3.lnk" "$INSTDIR\license.txt"
SectionEnd

Section "un.Uninstaller Section"
# always delete uninstaller first
delete $INSTDIR\uninstaller.exe
 
delete $INSTDIR\avi_joiner.exe
delete $INSTDIR\mencoder.exe
delete $INSTDIR\readme.txt
delete $INSTDIR\license.txt

delete "$SMPROGRAMS\AVI Joiner\avi_joiner.lnk"
delete "$SMPROGRAMS\AVI Joiner\uninstall.lnk"
delete "$SMPROGRAMS\AVI Joiner\readme.lnk"
delete "$SMPROGRAMS\AVI Joiner\GPL license v3.lnk"

RMDir "$SMPROGRAMS\AVI Joiner"
RMDir $INSTDIR

SectionEnd

