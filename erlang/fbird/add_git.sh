#!/bin/sh 

new_user=$1
new_git_dir=$2

useradd $new_user
usermod -g gitGroup $new_user

cd /git/git_repos/
mkdir $new_git_dir
chown $new_user:gitGroup ./$new_git_dir -R
cd ./$new_git_dir
echo "will create git in:`pwd`"
su $new_user -c "git --bare init --shared"
echo "The git repos url:"
echo -e "\t$new_user@192.168.1.237:/git_repos/$new_git_dir"
