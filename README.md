Manipulate tickets in Redmine via rbot

!tickets

Shows the assigned tickets for the user in redmine with the same login
name as the IRC nick name.

!tickets user

Shows the assigned tickets for the user in redmine with the same login
 name as stated as parameter.

SETUP

 * !config set redmine.host http://my.host/path
 * !config set redmine.channels #kaos
 * !config set redmine.botuser morpheus
 * !config set redmine.botuserpassword p4ssw0rd1337

As a default the maximum number of tickets shown is five, this can be
adjusted if you need less or more information displayed. Try to avoid
spamming the channels.

  !config set redmine.nbrofassignments 5

TODO

* Pagination
 * It would be nice to be able to step the assignements when there are
   many. !tickets 5 or !tickets 5 brother to show the comming
   assignments after the default ones. This is supported in the
   redmine REST API and not overly complicated to add.

* Alias
 * Not everyone uses their redmine login name as IRC nickname. Adding
   a mapping between a user and a login name would be
   useful. Something like !ticket alias redmineuser ircuser. As we use
   this in a slack environment it must be aware of the occasional use
   of @ prefix.  If you are changing the current user doing !tickets
   alias redmineuser could be nice.

Licensed as WTFPL.

Martin Bagge / brother