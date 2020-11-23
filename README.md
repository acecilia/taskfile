# Introducing the taskfile: stop using a Makefile for executing recurring tasks

## TL;DR

A `Makefile` has important limitations when using it to execute recurring shell tasks. 

A better alternative is to use a shell script with functions, which I called `taskfile`. Try it out by running the following command in your terminal, which will create a basic `taskfile` in the working directory:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/acecilia/taskfile/master/start.sh)"
```

## How did we end up here?

When a software project grows, most of the times you end up having a list of recurring tasks you need to perform from the top of the repository. For example, some simple ones: `build`, `test`, `release`...

There are multiple alternatives for organizing the code that each of these tasks implements: 

* In python, [it is possible to define each of the recurring tasks as a function inside a `py` file](https://dev.to/aahnik/is-there-a-makefile-alternative-where-we-can-run-code-in-python-114a)
* Users of `npm` even [have a specific tool for this](https://github.com/testdouble/scripty)
* As a language-agnostic solution, it is possible to store each of the recurring tasks in its own executable script and have a folder containing all of them. After, [use `direnv` to add them to the `PATH`](https://spin.atomicobject.com/2019/01/19/project-specific-cl-shortcuts/)

But let's focus on one of the most popular and widespread solutions: [to define each of the recurring tasks as a target inside a `Makefile`](https://www.digitalocean.com/community/tutorials/how-to-use-makefiles-to-automate-repetitive-tasks-on-an-ubuntu-vps).

## The good and the bad of a `Makefile`

Using a `Makefile` to store and execute these recurring tasks seems like a good solution at first: 

* Mostly everybody knows how to run a `Makefile` when they see it
* The `make` command line tool is multiplatform, and in many cases comes pre-installed in the OS, so no additional install steps are required
* The syntax looks clear: each repetitive task is define as a target
* Targets can depend on each other: running one task can trigger any other task in a specific order

```Makefile
build:
    bazel build ...
    
test: build
    bazel test ...
```

But as soon as the project grows and the recurring tasks become more complex than a one-line-command, some problems appear. What are supposed to be simple things become complex, verbose or not intuitive:

* [Executing multiline commands becomes verbose and difficult to read](https://stackoverflow.com/questions/10121182/multiline-bash-commands-in-makefile), because each line needs to be suffixed by `\`:

    ```Makefile
    my_target1:
        for i in $$(ls); do \
            echo "This is a file: $$i"; \
        done
    ```

* [Defining variables is difficult or impossible](https://stackoverflow.com/questions/1909188/define-make-variable-at-rule-execution-time), forcing us to rewrite the code in order to satisfy the `Makefile` syntax requirements:

    ```Makefile
    my_target2:
        $(eval MY_VAR := "this is a local variable")
        echo $(MY_VAR)
    ```

* [Introducing conditional execution requires extra knowledge of the `Makefile` syntax](https://stackoverflow.com/questions/15977796/if-conditions-in-a-makefile-inside-a-target), or to write the condition in shell syntax. This makes the code verbose and difficult to read

* Using shell variables requires escaping the `$` symbols, making the code more difficult to read:
    
    ```Makefile
    my_target3:
        echo "$$TMPDIR"
    ```

* Whe executing the task, all commands run inside it are printed by default. To avoid it, you need to prefix the command with `@` or to fully avoid printing the commands by [adding `.SILENT` to the top of the `Makefile`](https://stackoverflow.com/questions/24005166/gnu-make-silent-by-default/24011502):

    ```Makefile
    my_target4:
        @echo "hello world"
    ```

* A `Makefile` requires using tabs instead of spaces. This can lead to problems if mixing spaces and tabs, which will probably happen
* [There is no easy way to pass variables to the targets of a `Makefile`](https://stackoverflow.com/questions/2214575/passing-arguments-to-make-run)

You can understand how all this small issues become a main problem as this recurring tasks grow and increase in complexity. The problem is that we are missusing the `Makefile`: `make` is a build automation tool, and was never intended to be use as a shortland for recuring tasks.

## The alternative: taskfile

Most of the times, these recurring tasks are simple shell commands: the most ideal solution would be to write them inside a shell script file. We would also need a way of grouping the code based on the recurring tasks to perform. The solution is very simple: to use a shell script with functions inside.

```shell
#!/bin/zsh

set -euo pipefail # 1

name="Andres" # 2

say_hello() {
    surname="$1" # 3
    echo "Hello, I am $name $surname" # 4
}

# What this task does: Says hello and bye # 5
say_hello_and_bye() {
    say_hello $@ # 6
    echo "Bye!"
}

"$@" # 7
```

Let's go trough the details:

1. [`set -euo pipefail` enables a sort of strict mode for running the script](http://redsymbol.net/articles/unofficial-bash-strict-mode/)
2. It is possible to define global variables
3. It is possible to define local variables
4. It is possible to reuse global and local variables easily
5. It is possible to add comments and document your code
6. It is possible to have some tasks calling other tasks
7. This is what makes everything work: [executes all the parameters passed to the script as if they were a function](https://stackoverflow.com/a/16159057/3203441)

So the above script can be called as follows:

* Running it as `./taskfile_example.sh say_hello Cecilia` will print:

    ```
    Hello, I am Andres Cecilia
    ```

* Running it as `./taskfile_example.sh say_hello_and_bye Cecilia` will print:

    ```
    Hello, I am Andres Cecilia
    Bye!
    ```

* If you want to go the extra mile, you can rename the script as `taskfile` and add the alias `alias task="./taskfile"` to your shell, so calling the tasks inside the taskfile is even shorter. Some examples:

    ```shell
    task say_hello Cecilia
    task say_hello_and_bye Cecilia
    task build
    task test
    ```

## Try it out now

Running the following command from your terminal will create a basic `taskfile` in the working directory:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/acecilia/taskfile/master/start.sh)"
```
