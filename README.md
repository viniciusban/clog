clog.sh
=======

Generate CHANGELOG from your git history based on "close commands".

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

Why?
----

Due to several factors. See some:

1. Maintain a CHANGELOG file is a boring task.
1. I was looking for something useful to do with git history, beyond `git blame`.
1. I needed a motivation to write better, shorter and useful commit messages.
1. Don't repeat myself. If I wrote once (on commit message), I should not write it again (on CHANGELOG file).
1. The git history is sacred. It should never be modified. So, it's reliable.

I got inspiration on [clog - A conventional changelog generator for the rest of us](http://blog.thoughtram.io/announcements/tools/2014/09/18/announcing-clog-a-conventional-changelog-generator-for-the-rest-of-us.html), by thoughtram guys, but made something different:

- Simple and plain git and bash. No external dependencies.
- Unix pipe oriented. Or, outputs to stdout.
- Simpler commit message pattern. We just look for `[cC]loses #` pattern. No type, no changed module name, no formatting or grouping of messages.


How to use it?
--------------

When you close a ticket, write your commit message like this:

```
Bugfix #17 FTW! No more annoying messages on control panel.

It closes #17: remove wrong annoying message from control panel, asking for confirmation.

It was caused by... blah blah blah...

More blah blah blah...
```

Now, you go to terminal and:

```
$ clog.sh --title v1.6.1
v1.6.1
  - #17: remove wrong annoying message from control panel, asking for confirmation. (c67632b by john.doe)
```

It's that simple. What you wrote on your "close command" will be written to your commit message, appended with the commit SHA1 and the committer's email part before the "@" sign.

By default we start searching your git history for "close commands" from the last (in dictionary order) tag.


About release notes
-------------------

In the quest for really useful commit messages, you can also add some release notes instructions on it:

```
Create the Employee data structure...

Closes #456: Create table to store Employee data.

<release-notes>
- run in shell: $ python manage.py migrate my_app 0005_add_employee_table
- run in shell: $ python manage.py migrate my_app 0006_add_employee_contacts_table
- run in shell: $ convert_old_structure_to_new.sh
</release-notes>

```

If you have release notes instructions (the string `<release-notes>` alone in a line) in your commit messages, `clog.sh` will add a "\*rnotes\*" string at the line ending:

```
v1.6.1
- #456: Create table to store Employee data. (e37620a by mrs.smith) *rnotes*
```

How do I update my CHANGELOG file?
----------------------------------

Simply go to your terminal and:

```
$ echo "$(clog --title v1.5 | cat - CHANGELOG)" > CHANGELOG
```

In addition, to commit, generate a new annotated tag and push to origin:

```
$ git commit -a CHANGELOG -m 'Update CHANGELOG for v1.5'
$ git tag -a v1.5 -m 'v1.5'
$ git push --tag origin <branch_name>
```

If I were you: I'd put that in a bash function. ;-)


What are "close commands"?
--------------------------

They are predefined text patterns to say their repository hosting must close a ticket. You probably already use this facility.

The pattern is "<word> #123", where:
 - <word> must be: close, closed, closes, fix, fixes, fixed, resolve, resolves, resolved.
 - #123 is the ticket number. The "#" character must be present.

Now you can use them to generate a CHANGELOG.


Tips
----

- Close only one ticket by line.
- But you can close many tickets in one line if they solve the same problem. Just use the "closes #23, #25: <message>" pattern.
- Write your closing ticket line as you want to see in CHANGELOG.
- You can write your "close command" anywhere in your commit message and we use it. But it cannot span multiple lines.
- Use tags to identify your versions.


Collaborate
-----------

Fork and send a pull request. You are welcome.


LICENSE
-------

We use the MIT one. Se `LICENSE` file.
