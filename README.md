clog.sh
=======

Generate CHANGELOG from your git history.

```
$ cd ~/projects/my_repo
$ clog.sh --title v1.5
v1.5
  - #690: Protect tables from delete cascade. (2777fe4 by viniciusban)
  - #695: Control commits by hand. (c1cacb9 by john.doe)
  - #875: Correct source encoding. (478015d by mrs.smith)
```

You can type `--from` and `--to` arguments. Ask for help:

```
$ clog.sh --help
```

To update your CHANGELOG file:

```
$ clog.sh --title v1.5 | cat - CHANGELOG > CHANGELOG
```


Why?
----

See the motivation: [clog - A conventional changelog generator for the rest of us](http://blog.thoughtram.io/announcements/tools/2014/09/18/announcing-clog-a-conventional-changelog-generator-for-the-rest-of-us.html).


Differences
-----------

- Simple and plain git, bash and awk. No external dependencies.
- Simpler commit message pattern. We just look for "closes #" string. No type, no changed module.

Tips
----

- Close only one ticket by line.
- Write your closing ticket line as you want to see in CHANGELOG.
- You can write your "close command" anywhere in your commit message and we use it.

Collaborate
-----------

You are welcome. Fork and send a pull request.
