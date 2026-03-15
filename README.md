# PHP Apache Template
A minimal web server starter pack with:
 - my favorite .htaccess config for php routing
 - basic directory structure and php entry points
 - a top level error handler with developer friendly error response 
 - basic error page 
 - basic dark mode css
 - basic docker compose setup

## Universal Structure.

The project structure is compatible with docker and native apache and shared hosting setups.

All requests are redirected to the public/index.php.

An additional .htaccess and index.php outside the public folder allow the server to
run exactly the same when forced by shared hosting providers to put the entire repo in a public web root.

Additional htaccess for src/ blocks public access to source files regardless of server setup.

# Requires:
apache with mod_rewrite enabled and php.

# Recommended development setup:
- Clone the repo and delete the .git folder
- Run `composer init` and set up PSR-4 autoloading with src/ as the namespace root (default setting).

## Licence
Do what you want with this code.

It comes as is with no warranty, and the author
accepts no liability in any way for how it is used.

You do not have to keep a copy this license with the code,
once you delete it, the code is yours, and I expect no credit.
