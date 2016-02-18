# em
A Linux (C-shell) wrapper script for launching XEmacs/gnuclient

Starts either XEmacs (on current host) or gnuclient, depending on whether there is 
already an XEmacs process; this is determined by looking for the process or a tag file (.gnuhost)
in user's home directory.
With -n option, starts a new XEmacs process, skipping the gnuclient functionality.

.cshrc setup: gnuclient requires GNU_SECURE to be set. I recommend the following your .cshrc file:
if ( ! -e $GNU_SECURE ) then
    touch $GNU_SECURE >> /dev/null
endif
grep `hostname` $GNU_SECURE >> /dev/null
if ( $status ) then
    echo $HOST >> $GNU_SECURE
endif

Usage: em.csh [-n] [file(s)]
Note: within the script you might want to adjust variables XEMACS/XEMACS_OPTIONS/GNUCLIENT 
to suit your environment. If IGNORE_LOCAL_XEMACS_PROCESS is set to 0, and the .gnuhost tag file 
is missing, gnuclient tries to connect to the local running XEmacs process (if there is one).
