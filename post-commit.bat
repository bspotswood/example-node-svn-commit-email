@ECHO OFF

REM this batch file can be dropped in the "hooks" folder of your subversion repositories on
REM a Windows system and it will then invoke the coffee script command using the 
REM commit-email.coffee script to send out an email notification.
REM
REM Configuration: change the CD command below to point at where you placed the commit-email.coffee file
REM
REM This is part of an example article which can be found at:
REM http://brentscode.wordpress.com/2013/02/07/using-node-js-and-coffee-script-to-send-subversion-commit-notification-emails

REM SVN passes in the path to the repo and the revision as the 1st and 2nd arguments
SET REPOS=%1
SET REV=%2

REM Change to the svn_hooks folder where the script will actually be at
CD /D %REPOS%\..\svn_hooks

REM run the script to do the rest of the heavy lifting
node_modules\.bin\coffee.cmd commit-email %REPOS% %REV%