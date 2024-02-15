#!/usr/bin/env bash

aws_login () {
   local user_id=$1
   local user_key=$2
   local region=$3
   profile="automation_user"
   aws configure set aws_access_key_id "$user_id" --profile $profile
   aws configure set user_key_access_key "$user_key" --profile $profile
   aws configure set region "$region" --profile $profile
   export AWS_PROFILE=$profile
   cat ~/.aws/config
   echo "INFO: Currently you are logged in as"
   aws sts get-caller-identity

}

aws_logout () {
   unset AWS_PROFILE
   rm -rf ~/.aws
   echo "INFO: Logged out from user account"
}
