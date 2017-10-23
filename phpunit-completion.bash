#!bash
#
# phpunit-bash-completion
# ========================
#
# Copyright (c) 2017 [Stephan Jorek](mailto:stephan.jorek@gmail.com)
#
# Distributed under the 3-Clause BSD license
# https://opensource.org/licenses/BSD-3-Clause
#
# Bash completion support for [phpunit](https://phpunit.de)
#
# The completion routines support completing all options and arguments
# provided by PHPUnit.
#
# Need help? [RTFM](https://sjorek.github.io/phpunit-bash-completion)!
#

if type complete &>/dev/null && type compgen &>/dev/null; then

    _phpunit_options()
    {
        ( ${1} --help | grep -o -E "(\-\-[a-z0-9=-]+|-[a-z0-9])" ) 2>/dev/null
    }

    _phpunit_suites()
    {
        local line
        ( ${1} --list-suites | grep -E "^ - " | cut -f 3- -d " " ) 2>/dev/null | \
            while read line ; do
                if [[ "${line}" =~ " " ]] ; then
                    printf "%q\n" "\"${line}\""
                else
                    printf "%q\n" "${line}"
                fi
            done
    }

    _phpunit_groups()
    {
        local line
        ( ${1} --list-groups | grep -E "^ - " | cut -f 3- -d " " ) 2>/dev/null | \
            while read line ; do
                if [[ "${line}" =~ " " ]] ; then
                    printf "%q\n" "\"${line}\""
                else
                    printf "%q\n" "${line}"
                fi
            done
    }

    _phpunit_tests()
    {
        local line
        (
            ${1} --list-tests | \
            grep -E "^ - " | \
            cut -f 3- -d " " | \
            sed -e $'s|^.*::||g;s|\("[^"]*"\)|\\\n\\1|g;s|#\(.*\)$|\\\n"#\\1"|g' | \
            sort | \
            uniq
        ) 2>/dev/null | \
            while read line ; do
                printf "%q\n" "${line}"
            done
    }

    _phpunit_php_settings()
    {
        php -r 'array_map(function($k) { echo $k . PHP_EOL; }, array_keys(ini_get_all(null, false)));' 2>/dev/null
    }

    _phpunit()
    {
        local phpunit current previous options

        COMPREPLY=()
        phpunit="${COMP_WORDS[0]}"
        if type _get_comp_words_by_ref &>/dev/null; then
          _get_comp_words_by_ref -n = -n @ -n : -n '"' -n '#' -c current
          _get_comp_words_by_ref -n = -n @ -n : -n '"' -n '#' -p previous
        else
          current="${COMP_WORDS[COMP_CWORD]}"
          previous="${COMP_WORDS[COMP_CWORD-1]}"
        fi
        current=$( printf "%q" "${current}" )
        previous=$( printf "%q" "${previous}" )

        case "${previous}" in
            --coverage-html|--coverage-xml|--include-path|--whitelist)
                _filedir -d 2>/dev/null || COMPREPLY=($(compgen -d -- "${current}"))
                __ltrim_colon_completions "${current}"
                return 0
                ;;

            --bootstrap|-c|--configuration|--coverage-*|--log-*|--list-tests-xml|--testdox-*)
                _filedir 2>/dev/null || COMPREPLY=($(compgen -f -- "${current}"))
                __ltrim_colon_completions "${current}"
                return 0
                ;;

            --group|--exclude-group)
                options=$(_phpunit_groups "${phpunit}")
                mapfile -t COMPREPLY < <(IFS=$'\n' compgen -W "${options}" -- "${current}")
                __ltrim_colon_completions "${current}"
                return 0
                ;;

            --testsuite)
                options=$(_phpunit_suites "${phpunit}")
                mapfile -t COMPREPLY < <(IFS=$'\n' compgen -W "${options}" -- "${current}")
                __ltrim_colon_completions "${current}"
                return 0
                ;;

            --filter)
                options=$(_phpunit_tests "${phpunit}")
                mapfile -t COMPREPLY < <(IFS=$'\n' compgen -W "${options}" -- "${current}")
                __ltrim_colon_completions "${current}"
                return 0
                ;;

            -d)
                COMPREPLY=($(compgen -W "$(_phpunit_php_settings)" -- "${current}"))
                __ltrim_colon_completions "${current}"
                return 0
                ;;

            -h|--help|--list-*|--version)
                __ltrim_colon_completions "${current}"
                return 0
                ;;

        esac

        if [[ ${current} == -* ]]; then
            options=$(_phpunit_options "${phpunit}")
            COMPREPLY=($(compgen -W "${options}" -- "${current}"))
        else
            _filedir 2>/dev/null || COMPREPLY=($(compgen -f -- "${current}"))
        fi

        __ltrim_colon_completions "${current}"
        return 0
    }

    complete -o default -F _phpunit phpunit phpunit.phar \
        $( compgen -ca | grep -E "^phpunit" | grep -v -E "^phpunit(\\.phar)?$" )

fi
