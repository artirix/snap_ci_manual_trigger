# SnapCiManualTrigger

[![Gem Version](https://badge.fury.io/rb/snap_ci_manual_trigger.svg)](http://badge.fury.io/rb/snap_ci_manual_trigger)
[![Build Status](https://travis-ci.org/artirix/snap_ci_manual_trigger.svg?branch=master)](https://travis-ci.org/artirix/snap_ci_manual_trigger)
[![Code Climate](https://codeclimate.com/github/artirix/snap_ci_manual_trigger.png)](https://codeclimate.com/github/artirix/snap_ci_manual_trigger)
[![Code Climate Coverage](https://codeclimate.com/github/artirix/snap_ci_manual_trigger/coverage.png)](https://codeclimate.com/github/artirix/snap_ci_manual_trigger)

`SnapCiManualTrigger` will connect to Snap-CI's API and trigger a manual stage on 
a given pipeline or create a new pipeline.
 

It uses Snap-CI's API, with user and APIKEY, so it acts in a users name.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'snap_ci_manual_trigger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install snap_ci_manual_trigger

## Usage

The Service object can be used programmatically. 

```ruby
service = SnapCiManualTrigger.for user: snap_ci_user, 
                                  api_key: snap_ci_api_key,
                                  owner: owner,
                                  repository: repository, 
                                  branch_name: branch_name
                                  
# creates a new pipeline, and returns the ID
pipeline_id = service.new_pipeline

# triggers the stage "Deploy" in the new pipeline
running_pipeline_url = service.manual_stage stage: 'Deploy', pipeline_id: pipeline_id
 
 
# trigger the stage "Deploy" in a new pipeline in one command
running_pipeline_url = service.manual_stage_on_new_pipeline 'Deploy'
```

### Generate tasks

This gem adds a generator to create specific rake tasks that will make things easier.
 
We invoke the generator like this:

```shell
rails generate snap_ci_manual_trigger:rake_tasks my-org my-repo
```

And it will create a rake task for calling `manual_stage_on_new_pipeline` there. It will be used like this:

```shell
# this will call for the 'Deploy' stage in a new pipeline in my-org/my-repo in branch 'master'
rake snap_ci:my-org_my-repo[Deploy]

# this will call for the 'Deploy' stage in a new pipeline in my-org/my-repo in branch 'other_branch'
rake snap_ci:my-org_my-repo[Deploy,other_branch]
```

It reads the credentials from ENV (required):
 
- `SNAP_CI_USER`: Snap-CI username
- `SNAP_CI_API_KEY`: Snap-CI API Key

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/artirix/snap_ci_manual_trigger.


## CHANGES

### v.1.0.1

- indentation in generated rake tasks

### v.1.0.0

- Generators added
- major version bump since we now require railties, which could be a breaking change