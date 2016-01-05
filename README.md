# em
A Linux (C-shell) wrapper script for launching XEmacs/gnuclient

Starts either XEmacs (on current host) or gnuclient, depending on whether there is 
already an XEmacs process; this is determined by looking for the process or a tag file 
in user's home directory.
With -n option, starts a new XEmacs process, skipping the gnuclient functionality.

Usage: em.csh [-n] [file(s)]
Note: You might need to adjust variables XEMACS/XEMACS_OPTIONS/GNUCLIENT to suit 
your environment.
If IGNORE_LOCAL_XEMACS_PROCESS is set to 0, and the .gnuhost tag file is missing, 
gnuclient tries to connect to the local running XEmacs process (if there is one).
