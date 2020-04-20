# OBS deploy tool

This repository contains the [mina]("https://github.com/mina/mina-deploy") script to deploy `obs-api` to our reference server

### Features

- Check which package is available to be installed
- Check which was the last deployed commit
- Check if there is pending migrations
- View pending migrations
- View diff of pending changes
- Deploy with pending migrations
- Deploy without pending migrations

### How to use it

Since mina is a [rake Application](https://docs.ruby-lang.org/en/2.2.0/Rake/Application.html), it behaves exactly like rake, so to see all available tasks:

```$ mina -T```

Passing environment variables:

```$ PACKAGE_NAME=obs-api-test mina obs:package:available```

### How to install it

```$ git clone https://github.com/vpereira/obs-deploy```

```$ bundle install ```

```$ mina -T```


### How to contribute with code

The commands are implemented in the gem [obs_deploy](https://github.com/vpereira/obs_deploy)