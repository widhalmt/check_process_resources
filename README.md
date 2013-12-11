check_process_resources
=======================

Icinga / Nagios Plugin to monitor resource usage of processes

Introduction
------------

The first version of the plugin was taken from [Nagios Exchange](http://exchange.nagios.org/directory/Plugins/Operating-Systems/Linux/Check-Process-Resources/details) and was written by [Eli Keimig](http://www.ektechnologies.com/) and put under the GPL.

I put this up on github as a personal project because it lacks the quality and support I want for an official Project at [Netways](https://www.netways.org/) . Whenever I put some work into it for a Netways project, I will use my other email address for commits. You can find this project at [Github](https://github.com/widhalmt/check_process_resources)

I see quite a few chances for improvement in the original script and I hope it will not take long before I can fix most of them even though this is a "low priority" project. I will keep the ToDo list as issues on Github.

I know this is quite a big fuzz about a small script. To be honest I also want to use this as a real life playground to get used to Github, test some bash scripting best practices, and so on. My goal is of course a working script but I'm aware that a simpler version would do just as well. One of the resources for bash scripting best practices I use is [Greg's Wiki](http://mywiki.wooledge.org/BashGuide/Practices).

Usage
=====

The plugin has the usual `--help` Option for more information on usage. It has some default values so you can have quick results but you will want to set all values because the current version tells you every default value it uses on each and every run.

