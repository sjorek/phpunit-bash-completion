# [PHPUnit shell completion for Bash](https://sjorek.github.io/phpunit-bash-completion/)

The [`phpunit-completion.bash`](phpunit-completion.bash)
script provides shell completion in bash for [PHPUnit](https://phpunit.de).

The completion routines support completing all options and arguments provided by PHPUnit.


## Installation

1. Ensure you installed:
   * `bash` version >= 4.1
   * `bash-completion` version >= 2.0
   * `grep` in `$PATH`
   * `awk` in `$PATH`
   * `cut` in `$PATH`
   * `sed` in `$PATH`
   * `tr` in `$PATH`
   * ... and last but not least, `phpunit` version >= 6.4 of course!

2. Install `phpunit-completion.bash` file:
   * a.) Either, place it in a `bash-completion.d` folder, like:
       * `/etc/bash-completion.d`
       * `/usr/local/etc/bash-completion.d`
       * `~/.bash-completion.d`
   * b.) Or, copy it somewhere (e.g. `~/.phpunit-completion.sh`) and put the
     following line in your `.bashrc`:

     `source ~/.phpunit-completion.sh`
   * c.) If you're using [MacPorts](https://www.macports.org) then you should
     take a look at my [MacPorts-PHP](https://sjorek.github.io/MacPorts-PHP)
     repository.

3. Optionally nail down the php interpreter used to determine certain
   completions by adding the following line in your `~/.bash_profile`:

         `export PHPUNIT_COMPLETION_PHP=/path/to/your/php`


## Contributing

Look at the [contribution guidelines](CONTRIBUTING.md)


## Want more?

There is a [composer-bash-completion](https://sjorek.github.io/composer-bash-completion/)
complementing the bash-completion. And - once more - if you're using [MacPorts](http://macports.org),
take a look at my [MacPorts-PHP](https://sjorek.github.io/MacPorts-PHP/)
repository.

Cheers!
