---
title: ".htaccess 2 - rewrite"
date: 2015-12-06
draft: false
tags: ["tutorials"]
author: Evan Smith
image: defimg/htaccess2.png
---

# mod_rewrite is a pain in the ass

When people think of .htaccess configuration, the first thing that might pop into their minds is URL manipulation with mod_rewrite. But they’re often frustrated by mod_rewrite’s complexity. This tutorial will walk you through everything you need to know for the most common mod_rewrite tasks.

# What is mod_rewrite

mod_rewrite is an Apache module that allows for server-side manipulation of requested URLs. Incoming URLs are checked against a series of rules. The rules contain a regular expression to detect a particular pattern. If the pattern is found in the URL, and the proper conditions are met, the pattern is replaced with a provided substitution string or action. This process continues until there are no more rules left or the process is explicitly told to stop.

This is summarized in these three points:

* There are a list of rules that are processed in order.
* If a rule matches, it checks the conditions for that rule.
* If everything is a go, it makes a substitution or action.

# Enabling mod_rewrite

Enabling mod_rewrite is easy. For the purposes of this tutorial I’m only going to talk about linux \(specifically ubuntu\) because it’s the most common use case for an apache server. So in order to enable mod_rewrite, you can simply log into the server as an administrator and issue the following command:

```
# Enable the rewrite mod
sudo a2enmod rewrite

# Restart apache
sudo service apache2 restart
```
 

As always, anything that you can put in a .htaccess file can also be placed inside the global configuration file. With mod_rewrite, there is a small differences if you put a rule in one or the other. Most notably:

>If you’re putting […] rules in an .htaccess file […] the directory prefix (/) is removed from the REQUEST_URI variable, as all requests are automatically assumed to be relative to the current directory. – [Apache Documentation](http://httpd.apache.org/docs/2.2/rewrite/rewrite_intro.html#htaccess)

This is something to keep in mind if you see examples online or if you’re trying an example yourself: beware of the leading slash. I will attempt to clarify this below when we work through some examples together.

# Regular Expressions

This tutorial does not intend to teach you regular expressions. For those of you who are familiar with them, the regular expressions used in mod_rewrite seem to vary between versions of Apache. In Apache 2.0 they’re [Perl Compatible Regular Expressions (PCRE)](http://perldoc.perl.org/perlre.html). This means that many of the shortcuts you are used to, such as \w referring to [A-Za-z0-9_], \d referring to [0-9], and much more do exist. However, my particular hosting company uses Apache 1.3 and the regular expressions are more limited.

[Here’s a good tutorial on learning regular expressions](http://regexone.com/) as we’re not going to deal with them in this tutorial.

# Syntax

![syntax_rewriterule](/post-images/htaccess/syntax_rewriterule.webp)

![syntax_rewritecond](/post-images/htaccess/syntax_rewritecond.webp)

# Remove Hotlinking

Hotlinking, referred to as Inline Linking on Wikipedia, is the term used to describe one site leeching off of another site. Usually one site – the Leecher – will include a link to some media file \(let’s say an image or video\) that is hosted on another site, the Content Host. In this scenario, the Content Host’s servers are wasting bandwidth serving content to some other website.

```
# Give Hotlinkers a 403 Forbidden warning.
RewriteEngine on
RewriteCond %{HTTP_REFERER} !^http://example\.net/?.*$ [NC]
RewriteCond %{HTTP_REFERER} !^http://example\.com/?.*$ [NC]
RewriteRule \.(gif|jpe?g|png|bmp)$ - [F,NC]
```
 


Above, the RewriteRule is checking for the request of a file with any popular image extension, such as .gif, .png, or .jpg. Feel free to add other extensions to this list if you want to protect .flv, .swf, or other files.

The domains which are allowed to access this content are “example.net” and “example.com”. In either of these two instances, a Rewrite Conditions will fail and the substitution won’t occur. If any other domain makes an attempt, however – let’s say “sample.com” – then all the Rewrite Conditions will pass, the substitution will happen, and the [F] forbidden action will trigger.

# Give warning image

The previous example returns a 404 Forbidden warning when someone attempts to hotlink content from your server. You can actually go one step further, and send the hotlinker any resource of your choice! For instance, you can return a warning image with text stating, “hotlinking is not allowed”. This way, the abuser will realize their mistake and host a copy on their own server. The only required change is to follow through with the rewrite substitution, and provide your chosen image instead of the one being requested:

```
# Redirect Hotlinkers to "warning.png"
RewriteEngine on
RewriteCond %{HTTP_REFERER} !^http://example\.net/?.*$
RewriteCond %{HTTP_REFERER} !^http://example\.com/?.*$   [NC]
RewriteRule \.(gif|jpe?g|png|bmp)$ http://example.com/warning.png [R,NC]
```

 
# Custom 404 Page

One neat trick that you can do with htaccess is to determine if the current “URL Part” leads to an actual file or directory on the web server. This is an excellent way to create a custom 404 “File not Found” page. For example, if a user tries to fetch a page in a particular directory that doesn’t exist, you can redirect him to any page you wish, such as the index page or a custom 404 page.

```
# Generic 404 to show the "custom_404.html" page
# If the requested page is not a file or directory
# Silent Redirect: the user's URL bar is unchanged.
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule .* custom_404.html [L]
```

 

If the incoming request filename can’t be found, then this script loads a “custom404.html” page. Note that there is no [R] flag – this is a silent redirect, not a hard redirect. The user’s Location Bar will not change, but the contents of the page will be “custom404.html”.

# IfModule condition

If you have various mod_rewrite snippets that you want to easily distribute to other servers or environments, you might want to be careful. Any invalid directive in a .htaccess file will likely trigger an internal server error. So, if an environment you move the snippet to doesn’t support mod_rewrite, you could temporarily break it.

One solution to this problem is the “check” for the mod_rewrite module. This is possible with any module; simply wrap your mod_rewrite code in an <IfModule> block and you’ll be all set:

```
<IfModule mod_rewrite.c>

  # Turn on
  RewriteEngine on

  # Always remove www (with a hard redirect)
  RewriteCond %{HTTP_HOST} ^www\.example\.com$ [NC]
  RewriteRule ^(.*)$ http://example.com/$1 [R=301,L]

  # Generic 404 for anyplace on the site
  # ...

</IfModule>
```