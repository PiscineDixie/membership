#
# fabric file for deploying
#   fab -u root -f membership/deploy.py -H dixie backup deploy
#

import fabric.api

def backup():
    fabric.api.run("rm -rf /var/www/membership-prev")
    fabric.api.run("cp -a /var/www/membership /var/www/membership-prev")
    
def deploy():
    fabric.api.local("rsync -a --delete . %s@%s:/var/www/membership/." % (fabric.api.env.user, fabric.api.env.host))
    with fabric.api.cd("/var/www/membership"):
      fabric.api.run("bundle install --path vendor/bundle")
      fabric.api.run("RAILS_ENV=production bundle exec rake db:migrate")
    fabric.api.run("chown -R www-data.www-data /var/www/membership")
    fabric.api.run("apache2ctl graceful")
    fabric.api.run("wget https://apps.piscinedixiepool.com:8484/ -o /dev/null -O /dev/null")
    fabric.api.run("wget https://apps.piscinedixiepool.com:8484/public/aide -o /dev/null -O /dev/null")
    pass