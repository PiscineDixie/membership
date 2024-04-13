Application pour gerer le membership.

MacOS dev:
sudo /usr/local/mysql/bin/mysqld_safe
cd membership
./bin/rails server

Pour deployer:
 fab -H ec2-user@apps.piscinedixiepool.com backup deploy



