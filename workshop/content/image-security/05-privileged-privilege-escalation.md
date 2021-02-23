


Privileged containers can allow almost completely unrestricted host access. They share namespaces with the host system, eschew cgroup restrictions, and do not offer any security. They should be used exclusively as a bundling and distribution mechanism for the code in the container, and not for isolation.

Processes within the container get almost the same privileges that are available to processes outside a container Privileged containers have significantly fewer kernel isolation features root inside a privileged container is close to root on the host as User Namespaces are not enforced
Privileged containers shared /dev with the host, which allows mounting of the host’s filesystem They can also interact with the kernel to load kernel and alter settings (including the hostname), interfere with the network stack, and many other subtle permissions

Any container in a Pod can enable privileged mode, using the privileged flag on the security context of the container spec. 
This is useful for containers that want to use operating system administrative capabilities such as manipulating the network stack or accessing hardware devices. 
Processes within a privileged container get almost the same privileges that are available to processes outside a container.

Note: Your container runtime must support the concept of a privileged container for this setting to be relevant.


Change location to the `~/privileged-privilege-escalation` sub directory.


```execute
clear
cd ~/privileged-privilege-escalation
```

```execute
cat run-as-non-root.yaml
```

    apiVersion: v1
    kind: Pod
    metadata:
    creationTimestamp: null
    labels:
        run: run-as-non-root-pod
    name: run-as-non-root-pod
    spec:
    securityContext:
        runAsUser: 1000
        runAsGroup: 3000
    containers:
    - command:
        - sh
        - -c
        - sleep 1d
        image: busybox
        name: run-as-non-root-pod
        resources: {}
        securityContext:
            runAsNonRoot: true
    dnsPolicy: ClusterFirst
    restartPolicy: Never
    status: {}


In the configuration file, the `runAsUser` field specifies that for any Containers in
the Pod, all processes run with user ID 1000. The `runAsGroup` field specifies the primary group ID of 3000 for
all processes within any containers of the Pod. If this field is omitted, the primary group ID of the containers
will be root(0). Any files created will also be owned by user 1000 and group 3000 when `runAsGroup` is specified.
Since `runAsNonRoot` field is specified, the container must run as a non-root user. 
If true, the Kubelet will validate the image at runtime to ensure that it does not run as UID 0 (root) and fail to start the container if it does. 
If unset or false, no such validation will be performed. 


Create the container with no root access

```execute
kubectl create -f run-as-non-root.yaml
```

Not lets try to access some system functionalities 

```execute
kubectl exec -it run-as-non-root-pod -- sh 
```

Verify container is running as non-root

```execute
ps aux
```

```execute
sysctl kernel.hostname=something
```

Output - Read only filesystem

```execute
exit
```

Delete Pod

```execute
kubectl delete pod run-as-non-root-pod
```

Lets run the container as root and see if we able to perform "sysctl kernel.hostname=something"



```execute
cat run-as-root.yaml
```

    apiVersion: v1
    kind: Pod
    metadata:
    creationTimestamp: null
    labels:
        run: run-as-root-pod
    name: run-as-root-pod
    spec:
    # securityContext:
    #   runAsUser: 1000
    #   runAsGroup: 3000
    #   fsGroup: 2000
    containers:
    - command:
        - sh
        - -c
        - sleep 1d
        image: busybox
        name: run-as-root-pod
        resources: {}
        # securityContext:
        #   runAsNonRoot: true
    dnsPolicy: ClusterFirst
    restartPolicy: Never
    status: {}


Create the container 

```execute
kubectl create -f run-as-root.yaml
```

Not lets try to access some system functionalities 

```execute
kubectl exec -it run-as-root-pod -- sh 
```

Verify container is running as root

```execute
ps aux
```

```execute
sysctl kernel.hostname=something
```

Output - Read only filesystem

We still looking at same error, so its not just because of this. Even if we are running as root we still not allowed to run this.

```execute
exit
```

Delete Pod

```execute
kubectl delete pod run-as-root-pod
```

Lets try Privileged mode - 

Running a pod in a privileged mode means that the pod can access the host’s resources and kernel capabilities. 
You can turn a pod into a privileged one by setting the privileged flag to `true` (by default a container is not allowed to access any devices on the host).

```execute
cat privileged.yaml
```

    apiVersion: v1
    kind: Pod
    metadata:
    creationTimestamp: null
    labels:
        run: privileged-pod
    name: privileged-pod
    spec:
    containers:
    - command:
        - sh
        - -c
        - sleep 1d
        image: busybox
        name: privileged-pod
        resources: {}
        securityContext:
            privileged: true
    dnsPolicy: ClusterFirst
    restartPolicy: Never
    status: {}

Create the container 

```execute
kubectl create -f privileged.yaml
```

Not lets try to access some system functionalities 

```execute
kubectl exec -it privileged-pod -- sh 
```

```execute
sysctl kernel.hostname=something
```

This time it should work. Privileged mode for containers

```execute
exit
```

Delete Pod

```execute
kubectl delete pod privileged-pod
```