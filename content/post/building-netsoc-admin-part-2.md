---
title: "Building Netsoc Admin 1 Part 2"
date: 2016-01-15
draft: false
tags: ["dev", "archive"]
author: Evan Smith
image: defimg/pen-papers.jpg
---

# Building Netsoc Admin 1.0 (#2) – Models and Relationships

Models aren’t just pretty runway strutters with capes draped over one shoulder and a small pomeranian in the other, they’re a vital part of the MVC methodology (it’s in the name after all). Models will be our main way of representing the underlying database and the relationships on top of that.

This is part 2 of a series on Building Netsoc Admin. If you haven’t already, you can read the previous parts over here.

### Laravel ORM

Laravel provides a really nice interface for interacting with and exposing models (ooo la la). Laravel uses Eloquent ORM (Object-Relational Mapping) to handle its models and relationships. This will give us a nice way to add to, delete from, query and generally interact with the database. First thing’s first though, we need to architect our database and make sure we have something to interact with in the first place.

### Database Migrations

All of our definitions and changes to the database will happen in sequential migrations. Working from scratch, on an empty development database, it may seem like a pain to use migrations but their main benefit comes as you build on top of your software in the future. Each migration script has a specific change and a method to entirely reverse it.

That way, our database changes are almost like version controlled commits. We can easily migrate (commit our change), rollback (reverse a change) and refresh (rollback all changes then migrate all of them again). In this blog post, we’re going to run a series of basic table creations to house all our data.

#### Making Migrations

To begin with, we’ll login to our vagrant box with `vagrant ssh` and then `cd /var/www` to get to the root of our project. To create a migration for a new table, we can run:

```nginx
php artisan make:migrate create_users_table --create=users
```

If we wanted to just make a change to an already existing table, we can leave out the `–create` flag and it won’t include the create table script in the new file.

```nginx
php artisan make:migrate add_age_column
```

For more information and details on how to run migrations, please refer to Laravel’s Documentation.

#### Users

```nginx
php artisan make:migrate create_users_table --create=users
```

Will create a new file titled *[something]_create_users_table.php* in the *database/migrations* directory with the following boilerplate code:

```php
<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->increments('id');
            $table->rememberToken();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::drop('users');
    }
}
```

The function `up()` will be run during a migration and the function `down()` will be run during a rollback.

In this case, `up()` creates a new table with the following:

Auto-incrementing integer `id` that will be used as the primary key
The `remember_token` for remembering a user when they close their browser and come back later (it’s just like Facebook’s “remember me” checkbox when you’re logging in)
An `updated_at` and a `created_at` timestamp to log when every entry is created and updated
We’re going to put our own code in the `up()` function:

```php
public function up()
{
    Schema::create('users', function (Blueprint $table) {
        $table->increments('id');

        // Create VARCHAR / String columns
        $table->string('name');
        $table->string('student_id');
        $table->string('course');
        $table->string('graduation_year');

        // Create string column with max length 60
        $table->string('password', 60);

        /*
        |------------------
        | LDAP-SPECIFIC
        |------------------
        */
        // User's Group ID
        $table->string('gid');
        // User's Home Directory
        $table->string('home_directory');
        // The user's unique id number
        $table->string('uid_number');
        // "uid" string column that MUST be unique
        $table->string('uid')->unique();

        $table->rememberToken();
        $table->timestamps();
    });
}
```

Settings
The settings table is pretty straightforward, much easier than above. As before, we start with our make:migrate command.

```nginx
php artisan make:migrate create_settings_table --create=settings
```

And the replace the `up()` method with the following:

```php
public function up()
{
    Schema::create('settings', function (Blueprint $table) {
        $table->increments('id');

        // Create a string column for name
        $table->string('name');
        // Create a string column for the setting value
        $table->string('setting');
        $table->timestamps();
    });
}
```

MySQL Databases
Unfortunately, this ones a little trickier as we have to setup the relationship between the mysql_databases and the users table. Firstly, though, we create our file:

```nginx
php artisan make:migration create_mysql_db_table --create=mysql_databases
```

And we replace the `up()` method but, this time, we’re going to add a Foreign Key. If you’d like to learn more about Foreign Keys, check out W3Schools’ tutorial on the subject.

```php
public function up()
{
    Schema::create('mysql_databases', function (Blueprint $table) {
        $table->increments('id');
        $table->string('db_name');
        $table->timestamps();

        // We use an unsigned integer because the ->increments()
        // method uses unsigned integers on the users table
        $table->unsignedInteger('user_id');

        /*
        |------------------
        | Here, we are creating a foreign key, that:
        |   1) declares our column "user_id" as the foreign key
        |
        |   2) says our foreign key references the "id" column
        |      on the "users" table
        |
        |   3) if the user is deleted, it should also delete all
        |      of their entries in this table too
        |------------------
        */
        $table->foreign('user_id')
              ->references('id')->on('users')
              ->onDelete('cascade');
    });
}
```

This creates a db-layer relationship between our databases and our users, I’ll explain a little more about relationships a little further down within the models so don’t worry too much about it right now.

Now, though, we have to consider what happens when we rollback a migration. For the first time, we’ve gotta replace the default `down()` function in order to drop the foreign key as well. It’s fairly straightforward, we simply put in the following:

```php
public function down()
{
    Schema::table('mysql_users', function (Blueprint $table) {
        // There's a predefined format for how laravel names
        // foreign key indexes
        $table->dropForeign('mysql_databases_user_id_foreign');
    });
    Schema::drop('mysql_databases');
}
```

We’re leveraging the table schema to drop the foreign key and then drop the table afterwards.

MySQL Users
Creating mysql_users is the same as above so I’ll simply include the three code segments.

```nginx
php artisan make:migration create_mysql_users_table --create=mysql_users
```

```php
public function up()
{
    Schema::create('mysql_users', function (Blueprint $table) {
        $table->increments('id');
        $table->string('username');
        $table->string('password');
        $table->unsignedInteger('user_id');

        $table->timestamps();

        $table->foreign('user_id')
              ->references('id')->on('users')
              ->onDelete('cascade');

    });
}
```

```php
public function down()
{
    Schema::table('mysql_users', function (Blueprint $table) {
        $table->dropForeign('mysql_users_user_id_foreign');
    });
    Schema::drop('mysql_users');
}
```

Models
Models are bridges between the database layer and our code. They give us a way to extrapolate relationships and query data in a very easy, object-y way. It’s much more readable as well which is a bonus. To create a user, you create a user object and then the model creates all the relevant information in the database as well so, effectively, we’re dealing with two distinct layers in one singular method.

User Model
I’m going to start off with the “hardest” model simply because it’s the core of our application – the user. Since it’s a User model, we’ll have to use certain contracts to provide Authentication and PasswordResets.

A contract, if you’re unfamiliar, is an agreement a class has to fulfil to ensure it can perform the necessary functions required.

Below is the initial code for the User model we’ll place in `app/User.php`.

```php
<?php

namespace App;

use Illuminate\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Auth\Passwords\CanResetPassword;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Illuminate\Contracts\Auth\CanResetPassword as CanResetPasswordContract;

class User extends Model implements AuthenticatableContract, CanResetPasswordContract
{
    use Authenticatable, CanResetPassword;

    /*
     * The database table used by the model.
     */
    protected $table = 'users';

    /*
     * The attributes that are mass assignable.
     */
    protected $fillable = ['uid', 'name',
                            'password', 'gid', 'home_directory',
                            'uid_number', 'student_id', 'course',
                            'graduation_year'];

    /*
     * The attributes excluded from the model's JSON form.
     */
    protected $hidden = ['password', 'remember_token'];
}
```

However, the key thing we’re missing here is the relationship between our User model and the MySQL models I’ll be setting up next. We’ll return to this.

MySQLDatabase and MySQLUser
Generally, models are fairly simple. Your database’s column names go in the `$fillable` array and anything sensitive goes in `$hidden`. There’s a template for every model. Have a look at the similarities between our code for `app/MySQLDatabase.php` and `app/MySQLUser.php` below:

```php
MySQLDatabase.php
<?php

namespace App;

use Illuminate\Database\Eloquent\Model;


class MySQLDatabase extends Model
{
    /*
     * The database table used by the model.
     */
    protected $table = 'mysql_databases';

    /*
     * The attributes that are mass assignable.
     */
    protected $fillable = ['user_id', 'db_name'];

    /*
     * The attributes excluded from the model's JSON form.
     */
    protected $hidden = [];

}
```

```php
MySQLUser.php
<?php

namespace App;

use Illuminate\Database\Eloquent\Model;


class MySQLUser extends Model
{
    /*
     * The database table used by the model.
     */
    protected $table = 'mysql_users';

    /*
     * The attributes that are mass assignable.
     */
    protected $fillable = ['user_id', 'username', 'password'];

    /*
     * The attributes excluded from the model's JSON form.
     */
    protected $hidden = [];
}
```

#### Relationships

User <–> MySQLDatabase
Every user in our application will have a one-to-many relationship with MySQL databases. That is, every user may have 1 or more MySQL databases associated with them. As such, we’d like a way to use one to determine the other. We’ve already set up our foreign keys in the database, so all that’s left is representing the relationship in the Model.

As you can see from the diagram below, the user has a one-to-many relationship with the databases but the databases have a one-to-one relationship with the user. A user can have many databases but each database can only have one user.

![User to database relationship](/post-images/nsa-old-1/user-dbrelation-2.png)

Within the User model, we’ll add the following:

```php
public function databases(){
    return $this->hasMany('App\MySQLDatabase');
}
```

Now, whenever we want a user’s databases, we can use `User::find(1)->databases` and it’ll return an array of database objects associated with that user.

Conversely, to represent the other side of the relationship, we’ll add code to the MySQLDatabase model.

```php
public function user(){
    return $this->hasOne('App\User');
}
```

Then we can get any databases’ user with `MySQLDatabase::find(1)->user`.

User <–> MySQLUser
Finally, the netsoc account user and the MySQL user have a one-to-one relationship both ways which make it much easier to understand. This is because we will be using one MySQLUser to give someone database access via management GUI (such as PHPMyAdmin). It allows us to limit their permissions and monitor access.

![User to database relationship](/post-images/nsa-old-1/user-dbrelation-2.png)
![User to database user relationship](/post-images/nsa-old-1/user-mysqluser.png)
