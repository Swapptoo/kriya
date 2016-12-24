set :stage, :production
set :branch, 'stable'
set :repo_url, "git@github.com:thefantos/#{fetch(:application)}.git"

server 'kriya.ai', user: 'deployer', roles: %w{app web db}
