A security context defines privilege and access control settings for
a Pod or Container. Security context settings include, but are not limited to:

* Discretionary Access Control: Permission to access an object, like a file, is based on
[user ID (UID) and group ID (GID)](https://wiki.archlinux.org/index.php/users_and_groups).


Change location to the `~/dedicated-user-kubernetes` sub directory.

```execute
clear
cd ~/dedicated-user-kubernetes
```

## Set the security context for a Pod

To specify security settings for a Pod, include the `securityContext` field
in the Pod specification. 
The security settings that you specify for a Pod apply to all Containers in the Pod.
Here is a configuration file for a Pod that has a `securityContext` and an `emptyDir` volume:


    apiVersion: v1
    kind: Pod
    metadata:
    name: security-context-demo
    spec:
    securityContext:
        runAsUser: 1000
        runAsGroup: 3000
        fsGroup: 2000
    volumes:
    - name: sec-ctx-vol
        emptyDir: {}
    containers:
    - name: sec-ctx-demo
        image: busybox
        command: [ "sh", "-c", "sleep 1h" ]
        volumeMounts:
        - name: sec-ctx-vol
        mountPath: /data/demo


In the configuration file, the `runAsUser` field specifies that for any Containers in
the Pod, all processes run with user ID 1000. The `runAsGroup` field specifies the primary group ID of 3000 for
all processes within any containers of the Pod. If this field is omitted, the primary group ID of the containers
will be root(0). Any files created will also be owned by user 1000 and group 3000 when `runAsGroup` is specified.
Since `fsGroup` field is specified, all processes of the container are also part of the supplementary group ID 2000.
The owner for volume `/data/demo` and any files created in that volume will be Group ID 2000.


Create the Pod:

```execute
kubectl apply -f security-context.yaml
```

Verify that the Pod's Container is running:

```execute
kubectl get pod security-context-demo
```

Get a shell to the running Container:

```execute
kubectl exec -it security-context-demo -- sh
```

In your shell, list the running processes:

```execute
ps
```

The output shows that the processes are running as user 1000, which is the value of `runAsUser`:

```
PID   USER     TIME  COMMAND
    1 1000      0:00 sleep 1h
    6 1000      0:00 sh
...
```

In your shell, navigate to `/data`, and list the one directory:

```execute
cd /data
ls -l
```

The output shows that the `/data/demo` directory has group ID 2000, which is
the value of `fsGroup`.

```
drwxrwsrwx 2 root 2000 4096 Jun  6 20:08 demo
```

In your shell, navigate to `/data/demo`, and create a file:

```execute
cd demo
echo hello > testfile
```

List the file in the `/data/demo` directory:

```execute
ls -l
```

The output shows that `testfile` has group ID 2000, which is the value of `fsGroup`.

```
-rw-r--r-- 1 1000 2000 6 Jun  6 20:08 testfile
```

Run the following command:

```execute
id
```

```
uid=1000 gid=3000 groups=2000
```

You will see that gid is 3000 which is same as `runAsGroup` field. If the `runAsGroup` was omitted the gid would
remain as 0(root) and the process will be able to interact with files that are owned by root(0) group and that have
the required group permissions for root(0) group.

Exit your shell:

```execute
exit
```

Delete Pod

```execute
kubectl delete pod security-context-demo
```

## Set the security context for a Container

To specify security settings for a Container, include the `securityContext` field
in the Container manifest. 
Security settings that you specify for a Container apply only to
the individual Container, and they override settings made at the Pod level when
there is overlap. Container settings do not affect the Pod's Volumes.

Here is the configuration file for a Pod that has one Container. Both the Pod
and the Container have a `securityContext` field:


    apiVersion: v1
    kind: Pod
    metadata:
    name: security-context-demo-2
    spec:
    securityContext:
        runAsUser: 1000
    containers:
    - name: sec-ctx-demo-2
        image: gcr.io/google-samples/node-hello:1.0
        securityContext:
        runAsUser: 2000


Create the Pod:

```execute
kubectl apply -f security-context-2.yaml
```

Verify that the Pod's Container is running:

```execute
kubectl get pod security-context-demo-2
```

Get a shell into the running Container:

```execute
kubectl exec -it security-context-demo-2 -- sh
```

In your shell, list the running processes:

```execute
ps aux
```

The output shows that the processes are running as user 2000. This is the value
of `runAsUser` specified for the Container. It overrides the value 1000 that is
specified for the Pod.

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
2000         1  0.0  0.0   4336   764 ?        Ss   20:36   0:00 /bin/sh -c node server.js
2000         8  0.1  0.5 772124 22604 ?        Sl   20:36   0:00 node server.js
...
```

Exit your shell:

```execute
exit
```

Delete Pod

```execute
kubectl delete pod security-context-demo-2
```