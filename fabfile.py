#
# fabric file for deploying
#   fab -H ec2-user@apps.piscinedixiepool.com backup deploy
#
# Relies on the ssh key of runner to be in ec2-user/.ssh/authorized_keys

from invoke import task

@task
def backup(c):
    c.run("rm -rf membership-prev")
    c.run("cp -r /var/www/membership ./membership-prev")
    
@task
def deploy(c):
    c.sudo("rm -rf membership")
    c.local("rsync -vv -a --delete --exclude='vendor/*' --exclude='.git/*' --exclude=log/development.log  --exclude='tmp/*' . %s@%s:membership" % (c.user, c.host))
    c.run("cd membership && bundle install --deployment --path vendor/bundle")
    c.run("cd membership && RAILS_ENV=production bin/rails assets:precompile")
    c.run("cd membership && RAILS_ENV=production bundle exec rake db:migrate")
    c.sudo("chown -R apache:apache membership")
    c.sudo("rm -rf /var/www/membership")
    c.sudo("mv membership /var/www/.")
    c.sudo("systemctl reload httpd")
    c.run("wget http://localhost:8084/ -o /dev/null -O /dev/null")
    c.run("wget http://localhost:8084/public/aide -o /dev/null -O /dev/null")
    pass
