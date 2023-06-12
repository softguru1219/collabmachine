## Pour server collab @ ovh
set :stage, :production
server '158.69.82.71', user: 'collab', roles: %w{app db web}
set :branch, 'production'
set :deploy_to, '/home/collab/html/production'
set :bundle_flags, ''
