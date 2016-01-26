# SiteDumper

Once every programmer realizes that it was necessary to make a dumps.
SiteDumper creates a dump,
which includes a database dump and an archive of assets (it may includes pictures and other user generated content).
Dump is sent to the admin email.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'site_dumper'
```

And then execute:

    $ bundle

Generate config files:

    $ rails g site_dumper:install

Specify emails and other options in `config/initializers/site_dumper.rb`

## Usage

You can create and send dump using rake task:

    $ rake site_dumper:dump

For example, you can add cron job for every day backup:

    $ 0 0 *   *   *   cd <app_path> && bundle exec rake site_dumper:dump

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/site_dumper.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

