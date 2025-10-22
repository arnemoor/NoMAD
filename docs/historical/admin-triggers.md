***Script Triggers***

NoMAD has a number of triggers for scripts to act when a certain action has occurred. At this time no variables are passed to the command, however, as part of your script action you could query the NoMAD preferences using the ```defaults``` command to determine what user has been signed in and other information about the current user and environment.

***Sign On***

Specifying a script or binary path for the ```SignInCommand``` preference will run that command on each successful sign in. 

***Network Change***

Specifying a script or binary path for the ```StateChangeAction``` preference will run that command on each network change.

***Admin Command***

You can specify a script or binary path for the ```UserCommandTask1``` and a menu item name for ```UserCommandName1``` which will create a new menu item in the NoMAD main menu. When selecting this menu item the command specified will be run as the user. You can use this to allow users to trigger the action as they desire.

This command can be dynamically deployed and removed. There's no need to quit/launch NoMAD to enable or disable this functionality.