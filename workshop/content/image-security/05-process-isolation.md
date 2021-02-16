```execute
docker run --name c1 -d ubuntu sleep 1d
```

```execute
docker exec c1 ps aux
```

```execute
ps aux | grep sleep
```

```execute
docker run --name c2 -d ubuntu sleep 2d
```

```execute
docker exec c1 ps aux
```

```execute
docker exec c2 ps aux
```

```execute
docker rm c2 --force
```

```execute
docker run --name c2 --pid=container:c1 -d ubuntu sleep 2d
```

```execute
docker exec c1 ps aux
```

```execute
docker exec c2 ps aux
```