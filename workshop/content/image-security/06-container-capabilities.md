## Set capabilities for a Container

With [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html),
you can grant certain privileges to a process without granting all the privileges
of the root user. To add or remove Linux capabilities for a Container, include the
`capabilities` field in the `securityContext` section of the Container manifest.

First, see what happens when you don't include a `capabilities` field.
Here is configuration file that does not add or remove any Container capabilities:

    apiVersion: v1
    kind: Pod
    metadata:
    name: security-context-demo-3
    spec:
    containers:
    - name: sec-ctx-3
        image: gcr.io/google-samples/node-hello:1.0


Change location to the `~/container-capabilities` sub directory.

```execute
clear
cd ~/container-capabilities
```

Create the Pod:

```execute
kubectl apply -f security-context-3.yaml
```

Verify that the Pod's Container is running:

```execute
kubectl get pod security-context-demo-3
```

Get a shell into the running Container:

```execute
kubectl exec -it security-context-demo-3 -- sh
```

In your shell, list the running processes:

```execute
ps aux
```

The output shows the process IDs (PIDs) for the Container:

```
USER  PID %CPU %MEM    VSZ   RSS TTY   STAT START   TIME COMMAND
root    1  0.0  0.0   4336   796 ?     Ss   18:17   0:00 /bin/sh -c node server.js
root    5  0.1  0.5 772124 22700 ?     Sl   18:17   0:00 node server.js
```

In your shell, view the status for process 1:

```execute
cd /proc/1
cat status
```

The output shows the capabilities bitmap for the process:

```
...
CapPrm:	00000000a80425fb
CapEff:	00000000a80425fb
...
```

Make a note of the capabilities bitmap, and then exit your shell:

```execute
exit
```

Next, run a Container that is the same as the preceding container, except
that it has additional capabilities set.

Here is the configuration file for a Pod that runs one Container. The configuration
adds the `CAP_NET_ADMIN` and `CAP_SYS_TIME` capabilities:

    apiVersion: v1
    kind: Pod
    metadata:
    name: security-context-demo-4
    spec:
    containers:
    - name: sec-ctx-4
        image: gcr.io/google-samples/node-hello:1.0
        securityContext:
        capabilities:
            add: ["NET_ADMIN", "SYS_TIME"]

Change location to the `~/container-capabilities` sub directory.

```execute-2
clear
cd ~/container-capabilities
```


Create the Pod:

```execute-2
kubectl apply -f security-context-4.yaml
```

Get a shell into the running Container:

```execute-2
kubectl exec -it security-context-demo-4 -- sh
```

In your shell, view the capabilities for process 1:

```execute-2
cd /proc/1
cat status
```

The output shows capabilities bitmap for the process:

```
...
CapPrm:	00000000aa0435fb
CapEff:	00000000aa0435fb
...
```

Compare the capabilities of the two Containers:

```
00000000a80425fb
00000000aa0435fb
```

In the capability bitmap of the first container, bits 12 and 25 are clear. In the second container,
bits 12 and 25 are set. Bit 12 is `CAP_NET_ADMIN`, and bit 25 is `CAP_SYS_TIME`.
See [capability.h](https://github.com/torvalds/linux/blob/master/include/uapi/linux/capability.h)
for definitions of the capability constants.

Linux capability constants have the form `CAP_XXX`. But when you list capabilities in your Container manifest, you must omit the `CAP_` portion of the constant. For example, to add `CAP_SYS_TIME`, include `SYS_TIME` in your list of capabilities.
