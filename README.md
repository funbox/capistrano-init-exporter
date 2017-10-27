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

Configure the project as a normal project using capistrano for deployment. Then add to your ``Capfile`` :

    require 'capistrano/init_exporter'

In your `config/deploy.rb` :

    set :init_job_prefix, '<the prefix you want to be added to your project's processes>'

Install [init-exporter utility](https://github.com/funbox/init-exporter) on your server and confure it as you need. Do not forget to set `prefix` variable in `/etc/init-exporter.conf` :

    [main]

      ...

      # Prefix used for exported units and helpers
      prefix: <the prefix you want to be added to your project's processes>


To describe how your project should be started use procfiles version 2 as described [here](https://github.com/funbox/init-exporter#procfile-v2).