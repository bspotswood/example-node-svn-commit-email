###
# This script can be easily called from a subversion hook so that it can send out
# an email anytime that a commit is made to a repository.
#
# See: http://brentscode.wordpress.com/2013/02/07/using-node-js-and-coffee-script-to-send-subversion-commit-notification-emails
#
# Dependencies:
#   Node.js       - The execution platform for this script - download at: http://nodejs.org/
#   svnlook       - A svn command line program that gets details about a repo - installed as a part of SVN - http://subversion.apache.org/packages.html
#   coffee-script - the node module and language that this was created in
#   nodemailer    - a node module for sending email
#   recipients.js - A local node.js module where you can easily configure who receives email for which repos
#
# Configuration:
#   1. Install node.js and subversion if you have not already
#   2. Place this script and the recipients.js script in a folder, preferably near your SVN repositories
#   3. Open a command window to where you place the files and use npm to install coffee-script and nodemailer
#      a. npm install coffee-script
#      b. npm install 
#   4. Edit the CONFIG below to make it match your email server settings, path to svnlook, etc
#   5. Edit recipients.js to list your repositories, users, and which users get emails for which repos
#   6. Create a post-commit script file in the "hooks" subfolder of your repositories that you want to use this
#      a. The script (or DOS batch file) should execute the coffee command with this script, the repo path, and revision as arguments
#      b. An example for Windows has been provided
###
cp     = require 'child_process'
path   = require 'path'
mailer = require 'nodemailer' # install command: npm install nodemailer

recipients = require './recipients' # 


# Output command arguments
console.log i + ": " + process.argv[i] for i in [0..(process.argv.length-1)]

# Configuration - make sure to edit this for your server settings!
CONFIG = {
    EMAIL: {
        HOST:    'YOUR.EMAIL.SERVER.EXAMPLE.COM'
        FROM:    "'Example Sender Name' <your.from.email.account@example.com>"
        TO:      recipients(path.basename process.argv[2])
        SUBJECT: "[SVN Commit] " + process.argv[3] + ": " + path.basename process.argv[2] # [SVN Commit] REV: Repo
    }
    LINEBREAK: "\r\n" # windows line break, change for linux or mac
    SVNLOOK:   "C:\\svn\\bin\\svnlook.exe"
    REPOPATH:  process.argv[2]
    REVISION:  process.argv[3]
    REPONAME:  path.basename process.argv[2]
}


#--------------------------------------------------------------
# Calls svnlook to retrieve info based on the given command
# - callback is invoked with the 1st parameter containing the info as a string
svnlook = (command, repo, rev, svnlook_callback) ->
    spawn = cp.spawn CONFIG.SVNLOOK, [command, repo, '-r', rev]
    info  = ""
    
    spawn.stdout.on 'data', (data) ->
        info += data.toString()
    
    spawn.stderr.on 'data', (data) ->
        console.log 'svnlook error:', data.toString()
    
    spawn.on 'exit', (code) ->
        if code is 0
            svnlook_callback info
        else if code is 127
            console.log "svnlook could not be found."
        else
            console.log "The svnlook info request returned #{code}."


#--------------------------------------------------------------
# Get the basic information about the revision (user, date, message)
get_info = (get_info_callback) ->
    svnlook 'info', CONFIG.REPOPATH, CONFIG.REVISION, (info) ->
        info = info.split CONFIG.LINEBREAK
        get_info_callback 
            repo:    CONFIG.REPONAME
            rev:     CONFIG.REVISION
            path:    CONFIG.REPOPATH
            user:    info.shift()
            date:    new Date info.shift()
            msglen:  parseInt info.shift()
            message: info.join(CONFIG.LINEBREAK).trim()


#--------------------------------------------------------------
# Get an array of the changes that were committed
get_changed = (get_changed_callback) ->
    svnlook 'changed', CONFIG.REPOPATH, CONFIG.REVISION, (info) ->
        info = info.trim().split CONFIG.LINEBREAK
        changes = []
        for change in info
            changes.push
                code: change.substr(0,1)
                item: change.substr(1).trim()
        get_changed_callback changes


#--------------------------------------------------------------
# Function for sending out an email of the final status
send_email = (message) ->
    transport = mailer.createTransport "SMTP", {host: CONFIG.EMAIL.HOST}
    
    mail = 
        text:    message
        from:    CONFIG.EMAIL.FROM
        to:      CONFIG.EMAIL.TO
        subject: CONFIG.EMAIL.SUBJECT
    
    transport.sendMail mail, -> transport.close()


#--------------------------------------------------------------
# build a very basic message about the SVN commit and send it
get_info (info) -> get_changed (changes) ->
    console.log info
    console.log changes
    
    # This array will be joined with line breaks to make the actual message body
    message = [
        "A change to a project was committed."
        ""
        "Repository: #{info.repo}"
        "Revision:   #{info.rev}"
        "Author:     #{info.user}"
        "Date:       #{info.date}"
        ""
        "Commit message(s): "
        info.message
        ""
        ""
        "Changes:"
    ]
    
    # Used for giving a more descriptive list of changes
    change_code_text = 
        U: "* Updated: "
        A: "+ Added:   "
        D: "- Deleted: "
    
    # build out the final list of changes text
    for change in changes
        if change_code_text[change.code]
            message.push change_code_text[change.code] + change.item
        else
            message.push "? #{change.code}:       #{change.item}"
    
    console.log message = message.join CONFIG.LINEBREAK
    send_email  message