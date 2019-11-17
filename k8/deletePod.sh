#!/usr/bin/bash
filename='/tmp/uk1'
kubectl get pods --all-namespaces | grep $1 > $filename
while read -r line; do
    line="$line"
    fedName=`echo $line | awk '{print \$1}'`
    podName=`echo $line | awk '{print \$2}'`
    echo "$line"
    echo $fedName
    echo $podName
    kubectl delete pod $podName -n $fedName
done < "$filename"
