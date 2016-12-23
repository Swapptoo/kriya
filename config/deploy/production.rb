set :stage, :production
set :branch, 'stable'
set :repo_url, "git@github.com:thefantos/#{fetch(:application)}.git"

server '35.166.9.27', user: 'deployer', roles: %w{app web db}
