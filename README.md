setup duse
==========

The easiest way to setup your own duse instance uses
[Docker](https://www.docker.com/) and [Docker
Compose](https://docs.docker.com/compose/) on an Ubuntu 14.04 machine.

Vagrant
-------

To try the setup in a virtual machine, simply clone this repository and start
the vm.

> Hint: You will need [Vagrant](https://www.vagrantup.com/) and
> [Virtualbox](https://www.virtualbox.org/) or equivalent

Then clone this repo and simply run `vagrant up`. This automatically runs the
[bootstrap.sh](../blob/master/bootstrap.sh) explained below.

Once that's done you can directly jump to [setup](#setup).

After having started the application you can access it from your host at
`http://192.168.0.10:5000` or whatever port you configured it to.

Without Vagrant
---------------

Without vagrant you will simply need an Ubuntu 14.04 machine.

###Prerequisites

Run the [bootstrap.sh](../blob/master/bootstrap.sh) script, which does the following:

* install docker
* install docker-compose
* adds the vagrant user to the docker group
* modify some configs for docker to run smooth
* downloads the [docker-compose.yml](../blob/master/docker-compose.yml) from
  this repository to the current directory

###Setup

The [docker-compose.yml](../blob/master/docker-compose.yml) describes the
applications configuration. The first part describes the PostgreSQL server
setup.

```
db:
  image: postgres:9.4
  volumes:
    - ~/.docker-volumes/duse/db/:/var/lib/postgresql/data/
  ports:
    - "5432"
  environment:
    - POSTGRES_USER=duse
    - POSTGRES_PASSWORD=password #change this
```

> Hint: Configurations other than the environment variables can be ignored.

`POSTGRES_USER` describes the user to create for the API to use. A database of
the same name as the user is also created, keep this in mind in case you change
the user. Be sure to change the `POSTGRES_PASSWORD` as well.

The next section describes the configuration of the API itself.

```
web:
  image: duseio/api
  ports:
    - "5000:5000"
  links:
    - db
  environment:
    - EMAIL=noreply@duse.io # what address do you want emails to be sent from
    - HOST=duse.io          # required for building urls
    - SECRET_KEY=secretkey  # for secure authentication. Keep secret!
    - DATABASE_URL=postgres://duse:password@db/duse # adapt to change in db environment
    #- SENTRY_DSN=only set when you want to use sentry
    #- SSL=true             # you should be using SSL inproduction
    #- SMTP_HOST=           # host name of the smtp server to use
    #- SMTP_PORT=           # port of the smtp server to use
    #- SMTP_USER=           # smtp user you want to use
    #- SMTP_PASSWORD=       # smtp password of your user
```

By default the application is mapped to port `5000` of the docker host. If you
want to change that simply set it to `<port>:5000`. Other than that you will
only want to change the environment variables.

For the values of the environment variables see the [configuration
section](#configuration).

Once the your machine is up and running, has the prerequisites installed, and
you have configured your instance, simply run

	docker-compose run web rake db:migrate

It pulls the required docker images and applies the database migrations.

Now the applicaition is ready to use. Start with

	docker-compose up -d

Configuration
-------------

Duse is completely configured using environment variables. Here is a list of
all environment variables and what they are for.

> Info: Variables that are not labelled optional are mandatory

  * `HOST` the host to use when building links
  * `RACK_ENV` either "production" or "development" (using docker, production is default)
  * `SECRET_KEY` secret to sign api keys with
  * `SENTRY_DSN` (optional) sentry dsn (only set this if you want
    [sentry](https://getsentry.com/) logging)
  * `SSL` set to "true" if you want to use SSL (strongly recommended in
    production!)
  * `EMAIl` the email address you want emails to be sent from
  * `SMTP_HOST` (optional) the hostname of the smtp server to use
  * `SMTP_PORT` (optional) the port of the smtp server to use
  * `SMTP_USER` (optional) the smtp user name to authenticate to the smtp server
  * `SMTP_PASSWORD` (optional) the smtp user name to authenticate to the smtp server

> Hint: once you set `SMTP_HOST` it is assumed, that you want to use smtp.
> Otherwise `sendmail` will be used.

You can check if your configurations are valid with

	rake config:check

Or if you are using docker-compose then it would be

	docker-compose run web rake config:check
