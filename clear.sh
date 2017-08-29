#!/bin/bash

# exit on any error
#set -e

status=$(kubectl get namespace uaa | awk '$1=="uaa" {print $2}')
if [[ $status ]]; then
        echo "Namespace uaa status ${status}"
        if [ $status = "Active" ]; then
          kubectl delete namespace uaa
        elif [ $status = "Terminating" ]; then
          sleep 30  
        fi
else
       echo "Namespace uaa already deleted"
fi


status=$(kubectl get namespace cf | awk '$1=="cf" {print $2}')
if [[ $status ]]; then
        echo "Namespace cf status ${status}"
        if [ $status = "Active" ]; then
          kubectl delete namespace cf
        elif [ $status = "Terminating" ]; then
          sleep 30   
        fi
else
       echo "Namespace cf already deleted"
fi

sleep 10

kubectl delete -f  kube-external/pv.yaml

sleep 10

echo "Delete data directory"

sudo rm -rf /home/azureuser/data
mkdir -p /home/azureuser/data

echo "Create namespaces"

kubectl create namespace uaa
kubectl create namespace cf

kubectl create -f kube-external/pv.yaml

kubectl create -f ./src/uaa-fissile-release/kube/secrets/secret-1.yml -n uaa
kubectl create -f ./src/uaa-fissile-release/kube/bosh/mysql.yml -n uaa

sleep 2

CREATE_TIMEOUT=10

while (( --$CREATE_TIMEOUT >= 0)) ;do
     status=$(kubectl get pod mysql-0 -n uaa | awk '$1=="mysql-0" {print $2}')
     if [[ $status ]]; then
        echo "Pod mysql-0 status ${status}"
        if [ $status = "1/1" ]; then
          break
        fi
     else
       echo "Pod mysql for uaa not created"
       break
     fi
     sleep 30
done



kubectl create -f ./src/uaa-fissile-release/kube/bosh/uaa.yml -n uaa
kubectl create -f ./src/uaa-fissile-release/kube-test/exposed-ports.yml -n uaa

sleep 10

CREATE_TIMEOUT=10

while (( --$CREATE_TIMEOUT >= 0)) ;do
     status=$(kubectl get pod -l skiff-role-name=uaa -n uaa | grep uaa | awk '{print $2}')
     if [[ $status ]]; then
        echo "Pod uaa status ${status}"
        if [ $status = "1/1" ]; then
          break
        else
         sleep 10
        fi
     else
       echo "Pod uaa for uaa not created"
       break
     fi
     sleep 60
done


kubectl create --namespace="cf" --filename="kube/secrets"
kubectl create --namespace="cf" --filename="kube/bosh-task/post-deployment-setup.yml"
kubectl create --namespace="cf" --filename="kube/bosh"
kubectl create -f kube-external/api-external.yaml -n cf
