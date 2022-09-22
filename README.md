# PHP Apache Template
A minimal web server starter pack with:
 - my favorite .htaccess config for php routing
 - basic directory structure and php entry points
 - a top level error handler with developer friendly error response 
 - basic error page 
 - basic dark mode css

All requests for php files, directories, or sensitive files
are redirected to the public/index.php.

An additional failsafe .htaccess file and index.php in outside the public folder
ensure all requests will still land inside your projects
/public folder in case your hosting provider forces you to
put your entire project source code in a public html folder.

Requires php7 or higher.

## Licence
Do what you want with this code.

It comes as is with no warranty and the author
accepts no liability in any way for how it is used.

You do not have to keep a copy this licence with the code,
once you delete it the code is yours and I expect no credit.