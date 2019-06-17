---
title: ".htaccess - What is it?"
date: 2015-12-06
draft: false
tags: ["tutorials"]
author: Evan Smith
image: defimg/htaccess.webp
---

# What is Apache?

Apache is an open-source, widely-used web server. Although mostly cross-platform, Apache and Linux are generally the combination that’s used most. [According to this website I googled, apache accounts for 56.8% of all websites whose web server we know.](http://w3techs.com/technologies/details/ws-apache/all/all)

For the simplicity of this post, we’ll be only concerned with the latest version of apache (Apache2).

# What is .htaccess

.htaccess is a specific configuration file you can use to make config changes on a per-directory basis. It’s generally placed in the directory where the rules should apply and it’s a really handy way to:

1. Run several different types of application on a web server
2. Lockdown security (such as disabling PHP file execution)

## What Are Directives

A “directive” is essentially a rule for apache to follow. A .htaccess file allows us to execute a set/sequence of directives in one go.

# Enabling .htaccess

Apache has a default configuration that disables the use of .htaccess files. On a debian-based system, it’s located at `/etc/apache2/apache2.conf` and on a red-hat system, it’s located at `/etc/httpd/httpd.conf`.

If you scroll through your apache config file, you’ll notice that there are specific blocks of code laid out kind of like HTML tags. What these blocks are doing is scoping the directives inside them. That is, they’re limiting the amount of power rules have by only applying them to specific cases. For instance, `<Directory /var/www/html>`‘s block is scoping the directives to the “/var/www/html” directory.

The directive we’re concerned with, that controls the use of .htaccess files, is called `AllowOverride`. To enable .htaccess files, you can either allow them entirely or only allow specific directives. The latter can be handy if you’re planning shared hosting for a group of people as well as just minimising your attack surface overall.

## Allowing them entirely

So to allow .htaccess files entirely (in the web-specific directory only), search for the `<Directory /var/www/html>` block and change `AllowOverride none` to `AllowOverride All`. Your block should look a little like the following:

```
<Directory /var/www/>
	Options Indexes
	AllowOverride All
	Require all granted
</Directory>
```

## Limiting Directives

However, if you’d like to only make certain directives available, there are a set of options other than “All” that you can provide. Below is an example of one such set of rules:	

```
# Only allow .htaccess files to override Authorization and Indexes
AllowOverride AuthConfig Indexes
```

Here are the full set of options you can supply:

* AuthConfig – Authorization directives such as those dealing with Basic Authentication.
* FileInfo – Directives that deal with setting Headers, Error Documents, Cookies, URL Rewriting, and more.
* Indexes – Default directory listing customizations.
* Limit – Control access to pages in a number of different ways.
* Options – Similar access to Indexes but includes even more values such as ExecCGI, FollowSymLinks, Includes and more.

# Directives

Here a couple directives, their function and an example.
## Require (Access Control)

Require lets us choose who can and cannot access our websites. You can limit access entirely, by IP or by a wide variety of criteria.

```
# Allows everyone access to our websites
Require all granted

# Denies everyone access
Require all denied
```
 
## DirectoryIndex

This directive allows you to set filename/type that it should look for to display the default content of the webserver. The defaults are index.html and index.php. So if your server is at `wombats.org`, going to `wombats.org/my_folder/` will make apache go and search `/var/www/html/my_folder` (based on defaults) for one of the index files you specified.

```
<Directory "/var/www/html/my_folder">
    DirectoryIndex index.html index.php
</Directory>
```
 
## Options

The Options directive controls which server features are available in a particular directory. If you provide the values with a + or – like I did with -Indexes, then this will inherit the Options that were enabled in higher directories and the global configuration! If you don’t provide a + or – then the list that you provide will become the only options enabled for that directory and its subdirectories. No other options will be enabled. Because you may not know which Options were enabled previously, you will most likely use the + or – syntax unless you are absolutely sure you only want certain Options.

## Indexes

When a user requests a directory, Apache first looks for the default file. Typically, it will be named “index.html” or “index.php” or something similar. When it doesn’t find one of these files, it falls back on the mod_autoindex module to display a listing of the files and folders in that directory. Sometimes this is enabled, sometimes disabled, and sometimes you want to make customizations. Well, with .htaccess you can easily manipulate these listings! This is what the Indexes Option dictates.

```
<Directory "/var/www/html/my_folder">
    # Disable Directory Listings in this Directory and Subdirectories
	# This will hide the files from the public unless they know direct URLs
	Options -Indexes
</Directory>
```

# Basic Auth

Okay, maybe totally disabling the Directory Index is not what you want. It’s more likely that you want to keep the Indexes but only allow certain people access. That is where Basic Authentication can be very useful. This is the most common type of Authentication on the web. When the user tries to access the page they will see the familiar Username/Password dialog. Only a user with the proper credentials will be able to access the contents.

For basic authentication there are just two steps.

* Setup a .htpasswd file that stores usernames and password (encrypted).
* Add a few lines to .htaccess to use that file.

We’re going to assume your site is located at `/var/www/html/my_folder` and that your name is “Joe”. First, we’ll create the htpasswd file.

```
# Create the htpasswd file with a new password for the user "joe"
htpasswd -c /var/www/passwords/my_folder/.htpasswd joe
 
# Append user "mary" to the end of the file
htpasswd /var/www/passwords/my_folder/.htpasswd mary
```

This will create a .htpasswd file that will look a little like this:
	
```
joe:$apr1$QneYj/..$0G9cBfG2CdFGwia.AHFtR1
```

Next, we need to set up a .htaccess file in our website’s directory and tell it to use the authentication. Following the above, place your .htaccess file at `/var/www/html/my_folder/.htaccess` with the following contents:

```
<Directory "/var/www/html/protected">
  AuthType Basic
  AuthName "Authentication Required"
  AuthUserFile "/var/www/passwords/my_folder/.htpasswd"
  Require valid-user
</Directory>
```