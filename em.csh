#!/bin/csh -f
# ****************************************************************************************
# csh script (yes, awaits conversion to something better)
# Author: Thorsten Dworzak
# CreDate: 6.11.01
# Wrapper script for XEmacs and gnuclient.
# Starts either XEmacs (on current host) or gnuclient, depending on whether there is 
# already an XEmacs process; this is determined by looking for the process or a tag file 
# in user's home directory.
# With -n option, starts a new XEmacs process, skipping the gnuclient functionality.
#
# Usage: em.csh [-n] [file(s)]
# Note: You might need to adjust variables XEMACS/XEMACS_OPTIONS/GNUCLIENT to suit 
# your environment.
# If IGNORE_LOCAL_XEMACS_PROCESS is set to 0, and the .gnuhost tag file is missing, 
# gnuclient tries to connect to the local running XEmacs process (if there is one).
#
# ****************************************************************************************
set XEMACS="xemacs"
set XEMACS_OPTIONS="-debug-init"
set GNUCLIENT="gnuclient -q"
set IGNORE_LOCAL_XEMACS_PROCESS=1

onintr int
set hostname=`uname -n`

# check if arguments are for me
if (${1} =~ "-n") then
	set new_emacs=1
	shift
endif
 
# create a title/color for new XEmacs processes
set title = ""
set colour = "Gray"

# note: this code is site-dependent
`which project-view.sh` >&/dev/null
if ($status == 0) then
    set prj=`project-view.sh`
    set title="-title Project:$prj"
endif

# start a new editor if requested by user
if ($?new_emacs) then
	echo starting new XEmacs process requested by user...
   set colour = "DeepSkyBlue"
	${XEMACS} -bg $colour ${XEMACS_OPTIONS} $title $*
	exit
endif

# check if we are on a hosts that is in the list of foreign hosts
# if so, we use a different xemacs process
if (-e ~/.gnu_foreign_hosts) then
	grep $hostname ~/.gnu_foreign_hosts >/dev/null
	set result=$status
else
	set result=1
endif
if ( $result == 0 ) then
	set GHFILE="~/.gnuhost_foreign"
else
	set GHFILE="~/.gnuhost"
endif

# check env settings
if ( ! $?GNU_SECURE || ! -e $GNU_SECURE ) then
    echo "Warning: GNU_SECURE environment variable is not set or does not point to a readable file"
endif

# search running xemacs process
ps -edf|grep $USER|grep -v grep|grep -v nedit|grep gnuserv >/dev/null
set result=$status

if ($IGNORE_LOCAL_XEMACS_PROCESS == 1) then
    set result = 1;
endif

# check if no xemacs is running on this host and no tag file exists
if ($result == 1 && ! -e ${GHFILE}) then
	# set unix variable
	setenv GNU_HOST $hostname
	# create tag file
	echo $hostname > $GHFILE
	# call xemacs
	echo starting new XEmacs process...
	nohup ${XEMACS} -bg $colour $title ${XEMACS_OPTIONS} $*
   wait
	# remove tagfile after application quits
	/bin/mv $GHFILE ${GHFILE}.last
   echo end XEmacs process, moved $GHFILE to ${GHFILE}.last.
else
	# create tag file and launch gnuclient
	if ($result == 0 && ! -e ${GHFILE}) then
	    # if xemacs is running but no tagfile, create tagfile
	    echo `uname -n` > $GHFILE
	endif
   set other_host = $hostname
	if (-e ${GHFILE}) then
	    set other_host=`cat ${GHFILE}`
	endif
   if ($other_host != $hostname) then
       setenv GNU_HOST $other_host
   endif
	$GNUCLIENT $*
	# check for error
	set result=$status
	if ($result == 1) then
	    echo "Error occurred - try restarting gnuserv (in XEmacs: Alt-x, then type gnuserv-start)"
	    echo "or delete the tag file $GHFILE if you have no running XEmacs process."
       echo "Also, make sure that current host is in $GNU_SECURE."
	    echo "Note: DISPLAY is currently set to $DISPLAY"
	endif
endif
exit

# Signal Handler (usually XEmacs handles any interrupts, but sometimes they end up here)
int:
    if ( $?{GHFILE} ) then
	     /bin/mv $GHFILE ${GHFILE}.last
        echo Signal received, moved $GHFILE to ${GHFILE}.last.
    endif
