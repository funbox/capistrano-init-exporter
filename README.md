## `capistrano-init-exporter`

Capistrano bindings for the [init-exporter utility](https://github.com/funbox/init-exporter).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-init-exporter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-init-exporter

## Usage

Capify your project as described [here](https://github.com/capistrano/capistrano#capify-your-project).

Configure the project as a normal project which uses capistrano for deployment. Then add to your ``Capfile`` :

    require 'capistrano/init_exporter'

Install [init-exporter utility](https://github.com/funbox/init-exporter) on your server and configure it.

Use [procfiles version 2](https://github.com/funbox/init-exporter#procfile-v2) to describe how your project should be started .