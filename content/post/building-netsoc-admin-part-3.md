---
title: "Building Netsoc Admin 1 Part 3"
date: 2016-01-22
draft: false
tags: ["dev", "archive"]
author: Evan Smith
image: defimg/circle-apartments.jpg
---

# Building Netsoc Admin 1.0 (#3) – Layouts

Laravel provides an implementation of the Blade templating engine which lets us define generic templates for our data and page layouts. What I’m going to cover in this post is some really basic templates which we’ll base the rest of our designs off. We’re going to need two different layouts: a default full-width layout and a default with sidebar layout. Breaking those down further, we’ll also need a template for the header, the footer and the sidebar itself. So, let’s get to it!

(Note: I am going to assume a working knowledge of HTML5)

## Templates

To begin with anyway, all of our generic layout templates will live in resources/views/layouts so we can extend them later for more specific templates. As well as this, all of our files will end in .blade.php so signify that they are blade templates. If you’d like to read more about templating, I recommend having an ol’ sconce at the laravel documentation on the subject.

### Header.blade.php

To begin with, we’re going to need a <head> section, as well as somewhere to begin our <body> too. So here’s some generic boilerplate HTML to begin our project:

```html
<!DOCTYPE html>
<html>
<head>
	<title>Our Project</title>
	<meta charset="utf-8">

	<!-- Set the device width for mobile responsiveness -->
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
	<meta name="apple-mobile-web-app-capable" content="yes" />
	
	<!-- Give our project a nice favicon (choose one yourself) -->
	<link rel="shortcut icon" href="{{ URL::to('/') }}/images/favicon.png">
</head>
```

The first kind of laravel-specific thing we’re going to include is a `@yield()` for the site title. `@yield()` takes one mandatory parameter and one optional parameter as such: `@yield( 'some_name', 'default_value )`. The name can be anything you like which we’ll refer to in later templates. The purpose of `@yield()` is to set out placeholders for content/sections later on.

All the below is doing is saying that some of our pages will have their own title but, if not, use the SITE_TITLE variable in our .env file as the default.

```html
<title>@yield('title', env('SITE_TITLE'))</title>
```

Next, we’re gonna need a by of shtyling to make our website look pretty. So then, let’s include some required CSS for

FontAwesome – just some really awesome icons I prefer using to Materialize’s icons
MaterializeCSS – If you need an explanation why this is awesome

```html
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.5/css/materialize.min.css">
<link rel="stylesheet" type="text/css" href="{{ URL::to('/') }}/css/app.css">
```

Later on, we might need to include some extra stylesheets or add some extra tags to the head because Open Graph Tags are something every budding web developer should know (seriously, don’t build a project without them – it’s practically unshareable that way).

As such, we’re going to define two extra placeholder sections: one for extra CSS and one for extra header content.

```php
@yield('extra-css')

@yield('extra-head')
```

And, finally, we’re gonna add a placeholder for a custom body class so we can properly scope our styling.

```html
<body class="@yield('body-class')">
```

Here’s our full header.blade.php file for a proper overview.

```html
<!DOCTYPE html>
<html>
<head>
	<title>@yield('title', env('SITE_TITLE'))</title>
	<meta charset="utf-8">

    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<link rel="shortcut icon" href="{{ URL::to('/') }}/images/favicon.png">

	
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.5/css/materialize.min.css">
	<link rel="stylesheet" type="text/css" href="{{ URL::to('/') }}/css/app.css">
	@yield('extra-css')
	
	@yield('extra-head')
</head>
<body class="@yield('body-class')">
```

### Footer.blade.php

This one’s pretty simple after the above. It’s mostly just closing everything we started in the header file. There are three lines include the following scripts

jQuery – a requirement for Materialize (and the modern web imo)
MaterializeJS – adds all those cool components and effects we want to use
app.js – this is our own Javascript that we’re going to run

```html
	<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.5/js/materialize.min.js"></script>
	<script type="text/javascript" src="{{ URL::to('/') }}/js/app.js"></script>
	@yield('extra-js')
</body>
</html>
```

### Default.blade.php

Those two are all well and good but we don’t want to repeat ourselves and we’ll definitely want to deviate from the layout so something we’ll do here is stitch the two files together and put in our placeholder for a “content” section. This is the entire default.blade.php file:

```php
@include('layouts.header')

@yield('content')

@include('layouts.footer')
```

### Sidebar.blade.php

Here’s that fabled sidebar I just mentioned. When a user is logged in, they’re much more accustomed to a dashboard view of things for technical-type things (like AWS, Azure, facebook advertising, etc.). As such, there’s only one thing we absolutely need to adhere to in order to make sure navigation feels familiar – put our navigation in the sidebar. With Materialize, this is actually dead simple to do.

Below is the entire code of the sidebar but I’ve put in some helpful comments to help explain certain things. You don’t need to worry too much about the individual class names but if you’d like to learn more, you can check out the Materialize documentation.

```html
<aside>
	<div class="container">
		<!-- This is the "hamburger" icon that appears when someone
			 logs in on their mobile device. Clicking it, slides out
			 the same menu as below but smaller and customised for
			 their screen size - 'tis awesome 						-->
		<a href="#" data-activates="nav-mobile" class="button-collapse top-nav full hide-on-large-only">
			<i class="mdi-navigation-menu"></i>
		</a>
	</div>
	<ul id="nav-mobile" class="side-nav fixed">
        <li class="logo">
        	<a id="logo-container" href="{{ URL::route('home') }}" class="brand-logo">
        		<!-- display our logo, cause we're awesome and we made this -->
            	<img src="{{URL::to('/')}}/images/logo.png" />
            </a>
        </li>
        <!-- This will link to the homepage we'll create later when a person is logged in -->
        <li id="home"><a href="{{URL::to('/')}}" class="waves-effect waves-red">Home</a></li>

        <!-- We want people to be able to leave, because we're not saw -->
        <li id="logout"><a href="{{ URL::route('logout') }}" class="waves-effect waves-red">Logout</a></li>
        <!-- If someone finds a bug, we don't want them emailing us
        	 so we direct them to our issue tracker (as defined in 
        	 the .env file).										-->
        <li><a href="{{ env('ISSUE_TRACKER') }}">Report a bug</a></li>
    </ul>

</aside>
```

### default-with-sidebar.blade.php

As with our other default template, we’re just going to stitch together some of our base components and create a nice simple default layout for the admin area. It’s the same as before, we’re just going to use Materialize’s columns to define some constraints for the main content section and make sure it doesn’t ruin our view.

```html
@include('layouts.header')

<!-- Our entire page will be one row -->
<div class="row with-sidebar">
	<!-- Our side nav has a natural column width
		 so we won't define one here			-->
	@include('layouts.sidebar')
	
	<!-- The main content will need to be constrained
		 so it doesn't overflow behind the sidebar 	 -->
	<main class="col offset-l3 l9 s12">
		@yield('content')
	</main>
</div>

@include('layouts.footer')
```

## Wrap-Up
Well, that’s week 3 down and I hope you’re learning lots. These are just the base on top of which we build all of our views. It’s really simple to work with views within Laravel. I should have mentioned it above but anything within two sets of curly braces is executed as if it were a PHP command then echoed out (displayed on the web page). Later, we’ll pass data from our controllers to our views and fill our templates with actual, real-life data :O

Join us next week for another exciting episode of “Evan talks to himself about how he built NetsocAdmin so he doesn’t have to write actual documentation”!