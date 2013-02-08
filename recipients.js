/**
* This real simple module is used to build lists of people to email repo notifications to.
* It is part of an example about sending SVN commit notification emails, on my blog at:
* 
* http://brentscode.wordpress.com/2013/02/07/using-node-js-and-coffee-script-to-send-subversion-commit-notification-emails
*/

var users = {
    example: "'Example User' <example@brentscode.com>",
    another: "'Another User' <another@brentscode.com>"
};

var repos = {
    reponame: {
        recipients: [
            users.example,
            users.another
        ]
    }
    
    anotherrepo: {
        recipients: [
            users.example
        ]
    }
};



module.exports = function(repo) {
    return repos[repo].recipients.join(", ");
}