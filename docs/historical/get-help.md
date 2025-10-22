***Get Help Menu Options***

By default the "Get Help" menu will go to the Trusource Labs Bomgar instance, however, that doesn't have to be the case. The "Get Help" menu is configurable via ```defaults``` commands. There are two keys that you need to change.

- ```GetHelpType``` determines the type of action. Currently ```URL```, ```App```, and ```Bomgar``` are supported. ```URL``` will open the specified URL in the user's default browser. ```App``` will launch whatever path you have specified. Both of the following options are essentially just issuing an ```open``` command followed by either the URL or path. ```Bomgar``` is a bit more complicated in that it will ```curl``` down a Bomgar client application given the settings you specify, then open that app and initiate the Bomgar session.

- ```GetHelpOptions``` determines the payload for ```GetHelpType```. For ```URL``` just put in an http:// or https:// url. For ```App``` put in the full path for an app or other executable you want to launch. For ```Bomgar``` put in the URL of your Bomgar appliance. ***Note:*** \<\<fullname\>\>, \<\<serial\>\>, \<\<shortname\>\> and \<\<domain\>\> are supported substitutions in both the ```URL``` and ```Bomgar``` types.

***Bomgar URL Notes***

The process for getting the Bomgar client automatically launched involves three steps:
1. curl'ing down the client from your Bomgar Box or cloud URL supplying any custom variables. NoMAD will save this in ```/tmp/```
2. unzipping that client.
3. Launching the client.

For the URL it gets a bit complicated, as you have to specify a user agent as well to allow Bomgar to know which client to get you. Here's an example to work from:

```defaults write com.trusourcelabs.NoMAD GetHelpOptions '"https://bomgar.company.com/api/start_session -A \"Mozilla/5.0\\ (Macintosh;\\ Intel\\ Mac\\ OS\\ X\\ 10_11_4)\\ AppleWebKit/601.5.17\\ (KHTML,\\ like\\ Gecko)\\ Version/9.1\\ Safari/601.5.17\" -d issue_menu=1 -d session.custom.external_key=NoMAD -d session.custom.full_name=<<fullname>> -d session.custom.serial_number=<<serial>> -d customer.company=<<domain>>"'``

Note:  You need to ensure that you've created any custom variables in Bomgar that you want to use. In the example above, the custom variables are the ```session.custom.full_name``` and ```session.custom.serial_number``` have been added. ```session.custom.external_key``` should be setup by default and allows you to sort in your reports which users came in through NoMAD. To create the custom keys go to Management->API Configuration in the Bomgar admin ports.