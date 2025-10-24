######################### conectar con el EKS creado con terraform
# aws eks update-kubeconfig --region us-east-1 --name caleidos-eks --alias caleidos-eks --profile default

# kubectl get nodes
#kubectl get pods -n kube-system

#kubectl get pods -n kube-system | grep aws-load-balancer-controller


################ya con el eks arriba y los node-groups, instalar el HPA

#kubectl create deployment php-apache --image=k8s.gcr.io/hpa-example
#kubectl expose deployment php-apache --port=80
#kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

#kubectl autoscale deployment php-apache --cpu-percent=40 --min=1 --max=10 --namespace=default --version=autoscaling/v2

#kubectl get hpa
#kubectl get hpa -o wide
#kubectl describe hpa php-apache


####################### meterme al pod y hacerle un stress test
#kubectl get pods
#kubectl run -i --tty load-generator --image=busybox /bin/sh
#while true; do wget -q -O- http://php-apache; done

#kubectl exec -it <POD_NAME> -- /bin/bash


####################### revisar metricas del cluster
#kubectl get hpa php-apache -o yaml | grep apiVersion
#kubectl get pods -n kube-system -l app.kubernetes.io/name=metrics-server  ---> saco el nombre del pod
#kubectl logs -n kube-system <POD_NAME>  ---> reviso si hay errores en los logs
#kubectl top nodes
#kubectl top pods
#kubectl top pods --all-namespaces


## editar el deployment para que consuma mas cpu
#kubectl edit deployment php-apache

##### Editar el archivo y en spec/containers/ agregar:
# spec:
#       containers:
#       - image: k8s.gcr.io/hpa-example
#         imagePullPolicy: Always
#         name: hpa-example

#         resources:
#           requests:
#             cpu: "100m"
#             memory: "64Mi"
#           limits:
#             cpu: "500m"
#             memory: "128Mi"

#         terminationMessagePath: /dev/termination-log
#         terminationMessagePolicy: File
#       dnsPolicy: ClusterFirst
#       restartPolicy: Always
#       schedulerName: default-scheduler
#       securityContext: {}
#       terminationGracePeriodSeconds: 30

##retornar a la revision de las metricas del cluster y del hpa



#Si se tiene que eliminar 
#kubectl delete deployment php-apache
#kubectl delete service php-apache
#kubectl delete hpa php-apache
#kubectl delete pod load-generator

#kubectl autoscale deployment php-apache --cpu-percent=40 --min=1 --max=10 --namespace=default
#kubectl run -i --tty load-generator --image=busybox /bin/sh
#while true; do wget -q -O- http://php-apache; done