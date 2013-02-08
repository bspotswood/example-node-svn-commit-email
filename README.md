example-node-svn-commit-email
=============================
This script can be easily called from a subversion hook so that it can send out an email anytime that a commit is made to a repository. It is an example based on something I did at work and being written about for my blog. You can find the article discussing this at:

See: http://brentscode.wordpress.com/2013/02/07/using-node-js-and-coffee-script-to-send-subversion-commit-notification-emails

Dependencies:
=============
* Node.js       - The execution platform for this script - download at: http://nodejs.org/
* svnlook       - A svn command line program that gets details about a repo - installed as a part of SVN - http://subversion.apache.org/packages.html
* coffee-script - the node module and language that this was created in
* nodemailer    - a node module for sending email
* recipients.js - A local node.js module where you can easily configure who receives email for which repos

Configuration:
==============
1. Install node.js and subversion if you have not already
2. Place this script and the recipients.js script in a folder, preferably near your SVN repositories
3. Open a command window to where you place the files and use npm to install coffee-script and nodemailer
   a. npm install coffee-script
   b. npm install 
4. Edit the CONFIG below to make it match your email server settings, path to svnlook, etc
5. Edit recipients.js to list your repositories, users, and which users get emails for which repos
6. Create a post-commit script file in the "hooks" subfolder of your repositories that you want to use this
   a. The script (or DOS batch file) should execute the coffee command with this script, the repo path, and revision as arguments
   b. An example for Windows has been provided (post-commit.bat)
