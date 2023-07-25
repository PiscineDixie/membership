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
    c.run("rm -rf membership")
    c.run("git clone https://github.com/PiscineDixie/membership.git")
    c.local("rsync ./config/secrets.yml %s@%s:membership/config/." % (c.user, c.host))
    c.run("cd membership && env BUNDLE_DEPLOYMENT=1 bundle install")
    c.run("cd membership && env RAILS_ENV=production bin/rails assets:precompile")
    c.run("cd membership && env RAILS_ENV=production bundle exec rake db:migrate")
    c.run("rm -rf membership/.git")
    c.sudo("chown -R apache:apache membership")
    c.sudo("rm -rf /var/www/membership")
    c.sudo("mv membership /var/www/.")
    c.sudo("systemctl reload httpd")
    c.run("wget https://apps.piscinedixiepool:8484/ -o /dev/null -O /dev/null")
    c.run("wget https://apps.piscinedixiepool:8484/public/aide -o /dev/null -O /dev/null")
    pass
