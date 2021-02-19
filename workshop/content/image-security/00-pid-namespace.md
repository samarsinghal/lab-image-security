
Linux namespaces, including PID namespaces, are one of the key technologies that enable containers to run in isolated environments.

Every running program—or process—on a Linux machine has a unique number called a process identifier (PID). A PID namespace is a set of unique numbers that identify processes. Linux provides tools to create multiple PID namespaces. Each namespace has a complete set of possible PIDs. This means that each PID namespace will contain its own PID 1, 2, 3, and so on.

Without a PID namespace, the processes running inside a container would share the same ID space as those in other containers or on the host. A container would be able to determine what other processes were running on the host machine. Worse, namespaces transform many authorization decisions into domain decisions. That means processes in one container might be able to control processes in other containers. Docker would be much less useful without the PID namespace. The Linux features that Docker uses, such as namespaces, help you solve whole classes of software problems.

Docker runs processes in isolated containers. A container is a process which runs on a host. The host may be local or remote. When an operator executes docker run, the container process that runs is isolated in that it has its own file system, its own networking, and its own isolated process tree separate from the host.

Most programs will not need access to other running processes or be able to list the other running processes on the system. And so Docker creates a new PID namespace for each container by default. A container’s PID namespace isolates processes in that container from processes in other containers.

Let’s jump straight in with a practical example of PID namespaces in action.


Start container 'c1' and 'c2' with 'sleep 1d' and 'sleep 2d' process:

```execute
docker run --name c1 -d ubuntu sleep 1d
```

```execute
docker run --name c2 -d ubuntu sleep 2d
```

Now Exec in to container c1 and list the running processes:

```execute
docker exec c1 ps aux
```

The output shows all the processes that are running on the container, including 'sleep 1d' process:

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.2  0.0   2512   596 ?        Ss   05:06   0:00 sleep 1d
root         6  0.0  0.0   5900  2944 ?        Rs   05:06   0:00 ps aux
```

Now Exec in to container c2 and list the running processes:

```execute
docker exec c2 ps aux
```

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.2  0.0   2512   592 ?        Ss   19:37   0:00 sleep 2d
root         8  0.0  0.0   5900  3024 ?        Rs   19:37   0:00 ps aux
```


As can be seen in the listing above, processes residing in other container are not visible. What this indicates is that when the container is being run, any processes running inside of the container are by default isolated in docker.

By default, all containers have the PID namespace enabled.

PID namespace provides separation of processes. The PID Namespace removes the view of the system processes, and allows process ids to be reused including pid 1.

In certain cases you want your container to share the host’s process namespace, basically allowing processes within the container to see all of the processes on the system or process on other container. For example, you could build a container with debugging tools like strace or gdb, but want to use these tools when debugging processes within the container.


Remove  container c2 

```execute
docker rm c2 --force
```

Now create container c2 in c1 PID namespace 

```execute
docker run --name c2 --pid=container:c1 -d ubuntu sleep 2d
```

Now Exec in to both the containers and list the running processes:

```execute
docker exec c1 ps aux
```

```execute
docker exec c2 ps aux
```

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   2512   580 ?        Ss   19:37   0:00 sleep 1d
root         7  0.6  0.0   2512   532 ?        Ss   19:37   0:00 sleep 2d
root        13  0.0  0.0   5900  2972 ?        Rs   19:38   0:00 ps aux
```

We should see the output listing the processes in both the containers, As both are part of same PID namespace.

