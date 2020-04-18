# frozen_string_literal: true

require 'mina/rails'
require 'shellwords'

require 'bundler/setup'
require 'obs_deploy'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, ENV['DOMAIN'] || 'obs'
# if we don't unset it, it will use the default:
# https://github.com/mina-deploy/mina/blob/master/lib/mina/backend/remote.rb#L28
set :port, nil
set :package_name, 'obs-api'
set :product, ENV['PRODUCT'] || 'SLE_12_SP4'

set :user, ENV['user'] || 'root'
# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.
set :check_diff, ObsDeploy::CheckDiff.new(product: fetch(:product))

# Let mina controls the dry-run
set :zypper, ObsDeploy::Zypper.new(package_name: fetch(:package_name), dry_run: false)

namespace :obs do
  namespace :migration do
    desc 'migration needed'
    task :check do
      run(:local) do 
        puts "Pending Migration? #{fetch(:check_diff).has_migration?}" 
      end
    end
    desc 'show pending migrations'
    task :show do
      run(:local) do
        puts "Migrations: #{fetch(:check_diff).migrations}"
      end
    end
  end

  desc 'get diff'
  task :diff do
    run(:local) do
      puts "Diff: #{fetch(:check_diff).github_diff}"
    end
  end

  namespace :package do
    desc 'check installed version'
    task :installed do
      run(:local) do
        puts "Running Version: #{fetch(:check_diff).obs_running_commit}"
      end
    end
    desc 'check available version'
    task :available do
      run(:local) do
        puts "Running Version: #{fetch(:check_diff).package_version}"
      end
    end
  end
end

namespace :systemd do
  desc 'obs-api list systemctl dependencies'
  task :list_dependencies do
    run(:remote) do
      command Shellwords.join(ObsDeploy::Systemctl.new.list_dependencies)
    end
  end
  desc 'obs-api status'
  task :status do
    run(:remote) do
      command Shellwords.join(ObsDeploy::Systemctl.new.status)
    end
  end
end
# This task is the environment that is loaded for all remote run commands,
#  such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use', 'ruby-1.9.3-p125@default'
end

namespace :zypper do
  desc 'refresh repositories'
  task :refresh do
    command Shellwords.join(fetch(:zypper).refresh)
  end
  task update: :refresh do
    command Shellwords.join(fetch(:zypper).update)
  end
end

desc 'Deploys the current version to the server.'
task :deploy do
  invoke 'zypper:update'
end
