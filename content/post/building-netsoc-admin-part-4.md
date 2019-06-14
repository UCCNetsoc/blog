---
title: "Building Netsoc Admin 1 Part 4"
date: 2016-01-30
draft: false
tags: ["dev", "archive"]
author: Evan Smith
image: defimg/night-city.jpg
---

# Building Netsoc Admin 1.0 (#4) – Login & Registration

What use is a web admin if no one gets to login? It’s about as useful as giving each of our members a potato engraved with a special password that would give them and only them access to the secret Netsoc vault that exists beneath the catacombs of the Windle Building. So, this week, we’re dedicating an entire post to getting people registered and logged in – aren’t you lucky?

## Controller
A controller in an [MVC](/what-is-mvc/) architecture, will be the main manipulator of data and requests from people. Whenever someone sends a request to our web app, we’ll be pushing it through our controller and figuring out where things are meant to go and what information needs to follow them. Some of the following methods in the UserController class will be pretty sparse – maybe only a single line each – and that’s pretty standard for just creating generic views but we’ll also be handling the core of registering people and logging them in appropriately as well.

### UserController.php
In app/Http/Controllers/, create yourself a handy-dandy file called UserController.php which will control everything to do with users. We should put in the following boiler-plate code:

```php
<?php namespace App\Http\Controllers;
// The namespace is the scope within this file exists

// These are all the classes/packages this control relies on
// The following are optional in general but we will use all of them
use View;
use Auth;
use Response;
use Redirect;
use Request;
use Validator;
use Hash;
use App\User;
use App\Setting;

// Extend the generic Controller class - a mandatory step
class UserController extends Controller
{


}
```

### login() and register()
These two are just there to render views. They don’t add any information and they don’t really control anything – they’re just vehicles for our login and register forms. The code’s fairly straightforward and it just involves adding two methods to the UserController class.

```php
/**
 * Render registration view
 * @return VIEW register
 */
public function register( ){
    if( Auth::check( ) ){
        // If user is logged in, send 'em home
        return Redirect::route( 'home' );
    }

    // Render the Register view
    return View::make( 'auth.register' );
}

/**
 * Render login view
 * @return VIEW login
 */
public function login( ){

    if( Auth::check( ) ){
        // If user is logged in, send 'em home
        return Redirect::route( 'home' );
    }

    // Render the Login view
    return View::make( 'auth.login' );
}
```

We’ll be setting up the view files that correspond to these commands a little later but, before then, let’s move on to another handy function before the pièce de résistance.

### handleLogin()
What’s going to happen in this method, is the user’s going to submit the form in   login() which will forward all the data to handleLogin() which will process the data, assess whether you’re you and log you in if you are or flag an error on the form.

For starters, we just need to get the information from the form. Let’s start our method and filter our data to be only the fields we’re expecting – email and password.

```php
/**
 * Log a user into the system
 * @return REDIRECT home
 */
public function handleLogin( ){
    // Filter allowed data
    $data = Request::only([ 'email', 'password' ]);
}
```

The next step is to validate that input and make sure it is what it should be, however the only thing we’re going to be looking for is that the two fields are definitely filled in.

```php
$data = Request::only([ 'email', 'password' ]);

// Validate user input
$validator = Validator::make(
    $data,
    [
        'email' => 'required',
        'password' => 'required',
    ]
);

if($validator->fails()){
    // If validation fails, send back to the login form with errors
    return Redirect::route('login')->withErrors( $validator )->withInput( );
}
```

The Validator within Laravel is really nice and easy to work with. We pass in our data from the form and set out a series of parameters to check against the data. This one is just a simple example on making sure that the fields we need have been filled in. Then, we call the fails() method from the validator and check if our data is okay.

If the validator fails, we’re then going to send the person back to the login page along with what they put into the form ( ->withInput()) and with the errors we got during validation ( ->withErrors( $validator )).

Now, for the meat of the method! We’re actually going to check the user credentials and log the user in. Are you as excited as I am? (It’s a prerequisite of continuing so you’d better be!)

I’m gonna let the code (and the comments) do the talking on this one:

```php
// Check the entered credentials
if( Auth::attempt( [ 'email' => $data['email'], 'password' => $data['password']], true ) ){
    // If login is successful, send them to "home"
    return Redirect::route( 'home' );
} else {
    // Otherwise, tell them they're terrible at everything
    return Redirect::route( 'login' )
                   ->withErrors([ 
                        'message' => 'I\'m sorry, that username and password aren\'t correct.'
                    ]);
}

// If login was unsuccessful, send them to the login form
// with their email
return Redirect::route( 'login' )->withInput( );
```

### store()
Oh boy, oh boy, oh boy! Here we are, creating the user account. This bit will incorporate a lot of the handleLogin() method and show you how models are created/instantiated  in Laravel.

First, let’s take in the form info and validate it.

```php
/**
 * Creates a new user
 * 	Data should be POSTed to this function only
 * @return REDIRECT home
 */
public function store( ){
    // Only allow following fields to be submitted
    $data = Request::only( [
                'email',
                'password',
                'password_confirmation',
                'student_id',
                'graduation_year',
                'course',
                'name'
            ]);

    // Validate all input
    $validator = Validator::make( $data, [
                'email'             => 'required|unique:users|min:5',
                'student_id'        => 'numeric|required|unique:users',
                'password'          => 'required|confirmed|min:5',
                'graduation_year'   => 'required|numeric|digits:4',
                'course'            => 'required',
                'name'              => 'required'
            ]);


    if( $validator->fails( ) ){
        // If validation fails, redirect back to
        // registration form with errors
        return Redirect::back( )
                ->withErrors( $validator )
                ->withInput( );
    }
}
```

You’ll notice we’ve got a lot more validation parameters in this one. For example, this time we’re being much stricter on our email. From left to right: 1) The email is required. 2) The email must be unique in the users table. 3) It must be a minimum of 5 characters. I won’t go through the others so if you’d like to see all of the available rules, check out the documentation on the matter.

Once everything’s good to go, we’ll pass the data to the User model and create our user account (whoop whoop!).

```php
// Create new user locally
$newUser = User::create($data);
```

Is… is that it? Uh…

I know, it doesn’t look like much but, because our form names are the same names as our MySQL column names, we simply pass the verified data into the model and it then inserts the relevant info into our database. It’s a single line and it’s the minimum you’ll need for this function.

However, we want two things to happen after creation:

- Log them in automatically
- Redirect them to a new page

```php
if( $newUser ){
    // login user
    Auth::login($newUser);

    // If successful creation, go to the following page
    return Redirect::to( 'home' );
}

// If the creation failed, return with errors
return Redirect::back( )
            ->withErrors( [
                'message' => 'We\'re sorry but registration failed, please email '. env('DEV_EMAIL')
            ] )
            ->withInput( );
```

You’ll notice at the end there that I’ve also anticipated something going wrong in the creation process. If that happens we redirect back to the last page the user was on (the registration form) with their info (excluding their password).

### The Whole Thing

There’s a lot of bits and pieces here so I’ve put together a view of the whole file for you to copy and paste into your favourite editor. If you’re not interested in this, skip to the Views below.

```php
<?php namespace App\Http\Controllers;
// The namespace is the scope within this file exists

// These are all the classes/packages this control relies on
use View;
use Auth;
use Response;
use Redirect;
use Request;
use Validator;
use Hash;
use App\User;
use App\Setting;

class UserController extends Controller
{

/*
|--------------------------------------------------------------------------
| User Controller
|--------------------------------------------------------------------------
|
|
|
*/

    /*
    |------------------
    | VIEWS
    |------------------
    */

    /**
     * Render registration view
     * @return VIEW register
     */
    public function register( ){
        if( Auth::check( ) ){
            // If user is logged in, send 'em home
            return Redirect::route( 'home' );
        }

        // Render the Register view
        return View::make( 'auth.register' );
    }

    /**
     * Render login view
     * @return VIEW login
     */
    public function login( ){

        if( Auth::check( ) ){
            // If user is logged in, send 'em home
            return Redirect::route( 'home' );
        }

        // Render the Login view
        return View::make( 'auth.login' );
    }

    /**
     * Log out a user
     * @return REDIRECT login
     */
    public function logout( ){
        Auth::logout();
        return Redirect::route('login');
    }

    /*
    |------------------
    | FORM CONTROLS
    |------------------
    */

    /**
     * Creates a new user
     * Data should be POSTed to this function only
     * @return REDIRECT home
     */
    public function store( ){
        // Only allow following fields to be submitted
        $data = Request::only( [
                    'email',
                    'password',
                    'password_confirmation',
                    'student_id',
                    'graduation_year',
                    'course',
                    'name'
                ]);

        // Validate all input
        $validator = Validator::make( $data, [
                    'email'             => 'required|unique:users|min:5|alpha_num',
                    'student_id'        => 'numeric|required|unique:users',
                    'password'          => 'required|confirmed|min:5',
                    'graduation_year'   => 'required|numeric|digits:4',
                    'course'            => 'required',
                    'name'              => 'required'
                ]);


        if( $validator->fails( ) ){
            // If validation fails, redirect back to
            // registration form with errors
            return Redirect::back( )
                    ->withErrors( $validator )
                    ->withInput( );
        }

        // Create new user locally
        $newUser = User::create($data);

        if( $newUser ){
            // login user
            Auth::login($newUser);

            // If successful creation, go to the following page
            return Redirect::to( 'home' );
        }

        // If the creation failed, return with errors
        return Redirect::back( )
                    ->withErrors( [
                        'message' => 'We\'re sorry but registration failed, please email '. env('DEV_EMAIL')
                    ] )
                    ->withInput( );

    }

    /**
     * Log a user into the system
     * @return REDIRECT home
     */
    public function handleLogin( ){
        // Filter allowed data
        $data = Request::only([ 'email', 'password' ]);

        // Validate user input
        $validator = Validator::make(
            $data,
            [
                'email' => 'required',
                'password' => 'required',
            ]
        );

        if($validator->fails()){
            // If validation fails, send back to the login form with errors
            return Redirect::route('login')->withErrors( $validator )->withInput( );
        }

        // Check the entered credentials
        if( Auth::attempt( [ 'email' => $data['email'], 'password' => $data['password']], true ) ){
            // If login is successful, send them to "home"
            return Redirect::route( 'home' );
        } else {
            // Otherwise, tell them they're terrible at everything
            return Redirect::route( 'login' )
                           ->withErrors([
                                'message' => 'I\'m sorry, that username and password aren\'t correct.'
                            ]);
        }

        // If login was unsuccessful, send them to the login form
        // with their email
        return Redirect::route( 'login' )->withInput( );
    }

}
```

## Views
All of our views for this particular post will happen within the resources/views/auth folder. The auth folder is custom-made, so go ahead and create that first. Then move onto our view files. Remember, how we render these views was taken care of in the Controller above.

### login.blade.php
To begin all of our views, we’re going to be extending one of our default layouts we made in the last segment.

```php
@extends('layouts.default')
```

Next, we want to add a couple custom classes to our \<body\>. The first will be to leverage MaterializeCSS’ vertical alignment magic. The second, will be so we can accurately scope custom styling to just our login page.

```php
@section('body-class') valign-wrapper login @endsection
```

For the actual form, we need a section in our content that always applies our valign class for proper alignment on the screen. If you don’t understand the grid system or styling classes I’ve added, please have a sconse of the MaterializeCSS documentation to fully understand what’s going on (there’s kind of just too much to explain really).

```html
@section('content')
    <main class="row container">
        <section class="card-panel white col l6 offset-l3 s12 valign">

        </section>
    </main>
@stop
```

Inside that \<section\>, we’re gonna put our logo, a title and somewhere for our errors to show when things go wrong.

```html
<img src="{{ URL::to('/') }}/images/logo.png" class="form-logo"/>

<h3 class="center-align"> Login </h3>

<!-- All our errors will go in here as a handy-dandy list -->
@foreach ($errors->all() as $message)
    <li>{{ $message }}</li>
@endforeach
```

The URL::to('/') is used to get an absolute URL for the root of our application. This just means that we can easily move around the code from folder to folder or server to server and still be confident all the links and images will work.

The final step is to add the form. We’ll be using {!! and !!} around these blade elements as they need to be printed literally so as to avoid the blade engine automatically stripping out the HTML code – that would be kinda bad.

Here’s the view as a whole:

```html
@extends('layouts.default')

@section('body-class') valign-wrapper login @endsection

@section('content')
    <main class="row container">
        <section class="card-panel white col l6 offset-l3 s12 valign">
            <img src="{{ URL::to('/') }}/images/logo.png" class="form-logo"/>

            <h3 class="center-align"> Login </h3>

            <!-- All our errors will go in here as a handy-dandy list -->
            @foreach ($errors->all() as $message)
                <li>{{ $message }}</li>
            @endforeach

            <!-- Open the form and set it's action to the "user/login" route -->
            {!! Form::open([
                "route" => 'user/login',
                "method" => "POST",
                'class' => 'row col s12'
            ]) !!}

            <div class="row">
                <div class="input-field">
                    {!! Form::label('uid', 'Username (lowercase-only)') !!}
                    {!! Form::text('uid', null, ["class" => "example", "autofocus"] ) !!}
                </div>
            </div>

            <div class="row">
                <div class="input-field">
                    {!! Form::label('password', 'Password') !!}
                    {!! Form::password('password', null, ["class" => "example"] ) !!}
                </div>
            </div>

            <button class="btn waves-effect waves-light s12" type="submit" name="action">Login
                <i class="mdi-content-send right"></i>
            </button>

            <a href="{{ URL::route('register') }}">
                <button class="btn waves-effect waves-light s12 red lighten-2" type="button">Register
                    <i class="fa fa-plus"></i>
                </button>
            </a>
            {!! Form::close() !!}

            <br />
        </section>
    </main>
@stop
```

### Register.blade.php
Okay, so the registration form isn’t any different to the login form so I’m gonna do the cop-out thing and just give you all the code with a few comments.

```html
@extends('layouts.default')

@section('body-class') valign-wrapper register @endsection

@section('content')

<main class="row container">
    <section class="card-panel white col l6 offset-l3 s12 valign">
        <img src="{{ URL::to('/') }}/images/logo.png" class="form-logo"/>

        <h3 class="center-align"> Register </h3>
        @foreach ($errors->all() as $message)
            <li>{{ $message }}</li>
        @endforeach

        <!-- Open the form and set it's action to the "user/store" route -->
        {!! Form::open([
            "route" => ['user/store'],
            "method" => "POST",
            'class' => 'row col s12'
        ]) !!}

        <div class="row">
            <div class="input-field">
                {!! Form::label('name', 'Full Name') !!}
                <!-- Add the "autofocus" attribute so that it puts your cursor on the first input -->
                {!! Form::text('name', null, ["class" => "example", "autofocus"] ) !!}
            </div>
        </div>
        <div class="row">
            <div class="input-field">
                {!! Form::label('student_id', 'Student Number') !!}
                {!! Form::text('student_id', null, ["class" => "example"] ) !!}
            </div>
        </div>
        <div class="row">
            <div class="input-field">
                {!! Form::label('email', 'Username (lowercase-only)') !!}
                {!! Form::text('email', null, ["class" => "example"] ) !!}
            </div>
        </div>

        <div class="row">
            <div class="input-field">
                {!! Form::label('password', 'Password') !!}
                {!! Form::password('password', null, ["class" => "example"] ) !!}
            </div>
        </div>

        <!-- Required for the "confirm" validation -->
        <div class="row">
            <div class="input-field">
                {!! Form::label('password_confirmation', 'Confirm Password') !!}
                <!-- To work with the validator, the input name must be of the form:
                        {field-name}_confirmation where {field-name} is the name of the
                        field to be confirmed											-->
                {!! Form::password('password_confirmation', null, ["class" => "example"] ) !!}
            </div>
        </div>

        <div class="row">
            <div class="input-field">
                {!! Form::label('course', 'Your Course') !!}
                {!! Form::text('course', null, ["class" => "example"] ) !!}
            </div>
        </div>

        <div class="row">
            <div class="input-field">
                {!! Form::label('graduation_year', 'Your (Predicted) Graduation Year') !!}
                {!! Form::text('graduation_year', null, ["class" => "example"] ) !!}
            </div>
        </div>
        <button class="btn waves-effect waves-light" type="submit" name="action">Register
            <i class="mdi-content-send right"></i>
        </button>
        <!-- Close out the form -->
        {!! Form::close() !!}

        <br />
    </section>

</main>

@endsection
```

### App.less
Remember the app.less file in resources/assets/less? No, well, we’re going to need to add some style to our project. Otherwise, things are gonna look a little shitty. A lot of this is just styling and I’m assuming that because you have a grasp on HTML, you’re also familiar with some CSS so I won’t be explaining every design decision but have included them for the sake of completeness.

I’m leveraging LESS variables so that we can keep a consistent style throughout the application. For the most part, it’s just going to be some colours and our fonts. You can do much more complicated things (like mix-ins) but we only need some really simple stuff here.

```css
// Roboto's pretty, so let's use that!
@import url(https://fonts.googleapis.com/css?family=Roboto:600,400,300|Roboto+Slab);

/* COLOURS */
@offblack: #111;
@offwhite: #fffff8;
@red-lighten-1: #ef5350;
// Materialize's teal colour
@teal: #009688;

    /* Wordpress' signature blue for later */
    @wordpress-blue: #21759b;

/*FONTS */
@heading-stack:     'Roboto Slab', serif;
@fontstack:         'Roboto', sans-serif;


html{
      height: 100%;
      font-family: @fontstack;
      font-weight: 300;

    body {
        min-height: 100%;
        background: @offwhite;
        color: @offblack;

        &.register, &.login{
            .form-logo{
                width: 100%;
                padding: 20px 10px 0px;

                & + h3{
                    padding: 0px;
                    margin: 0px;
                }
            }
        }
    }

    h1,h2,h3,h4,h5{
        font-family: @heading-stack;
    }

    // Make the hamburger icon on mobile be a nice black,
    // bigger and float to the right-hand side
    .button-collapse.top-nav.full.hide-on-large-only i{
        font-size: 4em;
        color: @offblack;
        float: right;
    }
}
```

### Routes.php
Finally, we’ve got to actually set up a way to get to our forms – as well as where they go. The Routes file is located at app/Http/routes.php. Every route we’re dealing with will be of the form:

```php
Route::{HTTP_METHOD}( {URL}, ['as' => {ROUTE_NAME}, 'uses' => {CONTROLLER_AND_HANDLER_METHOD}]);
```

{HTTP_METHOD} determines what kind of request can access that route. The main ones I’ll be dealing with in this tutorial are GET (views) and POST (form submissions) requests.
{URL} sets out the structure for accessing the route
{ROUTE_NAME} is the nickname we’ll give to the route to access it again later
{CONTROLLER_AND_HANDLER_METHOD} is, as the name suggestions, which controller we’re using and which method inside the controller.
Now that you know what each of the sections means, here are the routes we need to add for authentication:

```php
Route::get('/register', ['as' => 'register', 'uses' => 'UserController@register']);
Route::post('/user/store', ['as' => 'user/store', 'uses' => 'UserController@store']);

Route::get('/login', ['as' => 'login', 'uses' => 'UserController@login']);
Route::post('/user/login', ['as' => 'user/login', 'uses' => 'UserController@handleLogin']);
Route::get('/logout', ['as' => 'logout', 'uses' => 'UserController@logout']);
```
