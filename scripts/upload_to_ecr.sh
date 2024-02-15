#!/usr/bin/env bash
source aws_authentication.sh

repository_name="${1}"
tag="${2:-latest}"

build_docker_file() {
  repository_name="${1}"
  tag="${2}"

  docker build . -t ${repository_name}
}

auth_to_ecr() {
  region=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[0].[RegionName]' --output text)
  aws_account_id=`aws sts get-caller-identity --query 'Account' --output text`
  ecrURL=${aws_account_id}.dkr.ecr.${region}.amazonaws.com
  ecrUserName=AWS
  ecrUserPassword=`aws --region ${region} ecr get-login-password`
  docker login --username ${ecrUserName} --password ${ecrUserPassword} ${ecrURL}
}

push_image_to_ecr() {
  repository_name="${1}"
  tag="${2}"

  build_docker_file ${repository_name} ${tag}
  auth_to_ecr
  docker tag ${repository_name}:${tag} ${ecrURL}/${repository_name}:${tag}
  docker push ${ecrURL}/${repository_name}:${tag}

}
main() {
  push_image_to_ecr ${repository_name} ${tag}
}

main