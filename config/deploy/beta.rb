## Pour server collab @ ovh
set :stage, :beta
server '158.69.82.71', user: 'collab', roles: %w{app db web}
set :branch, 'beta'
set :deploy_to, '/home/collab/html/beta'
set :bundle_flags, ''
