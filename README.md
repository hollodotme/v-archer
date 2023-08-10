# v-archer

Tools for architectural decomposition and descision making written in V

## Build

```shell
make
```

## Run tests

```shell
make test
```

## Update V and project dependencies

```shell
make update
```

## Command line interface

You have to run `make` first to build the binary in `./bin/v-archer`.

You can check the options for each CLI command by running `./bin/v-archer help <command>`.

### Identify and size

This command will identify all software components in a given path and calculate their size.

```shell
./bin/v-archer identify-and-size [path_to_project]
```
