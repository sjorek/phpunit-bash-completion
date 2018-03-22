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

PHPUNIT_COMPLETION_REGISTER=${PHPUNIT_COMPLETION_REGISTER:-"phpunit phpunit.phar"}
PHPUNIT_COMPLETION_DETECTION=${PHPUNIT_COMPLETION_DETECTION:-false}

if type -t _get_comp_words_by_ref >/dev/null ; then

    phpunit-completion-warmup-cache()
    {
        if [ "${1}" = '' ] ; then
            echo 'Missing name of phpunit executable as first argument'
        else
            phpunit-completion-clear-cache

            echo ''
            echo 'Cache phpunit completion:'

            echo -n '- cache option completion: '
            _PHPUNIT_COMPLETION_OPTIONS=$(_phpunit_completion_options ${1})
            echo 'done.'

            echo -n '- cache suite completion: '
            _PHPUNIT_COMPLETION_SUITES=$(_phpunit_completion_suites ${1})
            echo 'done.'

            echo -n '- cache group completion: '
            _PHPUNIT_COMPLETION_GROUPS=$(_phpunit_completion_groups ${1})
            echo 'done.'

            echo -n '- cache test completion: '
            _PHPUNIT_COMPLETION_TESTS=$(_phpunit_completion_tests ${1})
            echo 'done.'

            echo -n '- cache php setting completion: '
            _PHPUNIT_COMPLETION_PHP_SETTINGS=$(_phpunit_completion_php_settings)
            echo 'done.'
        fi
    }

    phpunit-completion-clear-cache()
    {
        echo -n 'Purge phpunit completion cache: '
        unset _PHPUNIT_COMPLETION_OPTIONS
        unset _PHPUNIT_COMPLETION_SUITES
        unset _PHPUNIT_COMPLETION_GROUPS
        unset _PHPUNIT_COMPLETION_TESTS
        unset _PHPUNIT_COMPLETION_PHP_SETTINGS
        echo 'done.'
    }

    _phpunit_completion_options()
    {
        if declare -p _PHPUNIT_COMPLETION_OPTIONS >/dev/null 2>&1 ; then
            echo "${_PHPUNIT_COMPLETION_OPTIONS}"
        else
            ( ${1} --help | grep -o -E "(\-\-[a-z0-9=-]+|-[a-z0-9])" ) 2>/dev/null
        fi
    }

    _phpunit_completion_suites()
    {
        local line
        if declare -p _PHPUNIT_COMPLETION_SUITES >/dev/null 2>&1 ; then
            echo "${_PHPUNIT_COMPLETION_SUITES}"
        else
            ( ${1} --list-suites | grep -E '^ - ' | cut -f 3- -d ' ' ) 2>/dev/null | \
                while read line ; do
                    if [[ "${line}" =~ ' ' ]] ; then
                        printf "%q\n" "\"${line}\""
                    else
                        printf "%q\n" "${line}"
                    fi
                done
        fi
    }

    _phpunit_completion_groups()
    {
        local line
        if declare -p _PHPUNIT_COMPLETION_GROUPS >/dev/null 2>&1 ; then
            echo "${_PHPUNIT_COMPLETION_GROUPS}"
        else
            ( ${1} --list-groups | grep -E '^ - ' | cut -f 3- -d ' ' ) 2>/dev/null | \
                while read line ; do
                    if [[ "${line}" =~ ' ' ]] ; then
                        printf "%q\n" "\"${line}\""
                    else
                        printf "%q\n" "${line}"
                    fi
                done
        fi
    }

    _phpunit_completion_tests()
    {
        local line
        if declare -p _PHPUNIT_COMPLETION_TESTS >/dev/null 2>&1 ; then
            echo "${_PHPUNIT_COMPLETION_TESTS}"
        else
            (
                ${1} --list-tests | \
                grep -E '^ - ' | \
                cut -f 3- -d ' ' | \
                sed -e $'s|^.*::||g;s|\("[^"]*"\)|\\\n\\1|g;s|#\(.*\)$|\\\n"#\\1"|g' | \
                sort | \
                uniq
            ) 2>/dev/null | \
                while read line ; do
                    printf "%q\n" "${line}"
                done
        fi
    }

    _phpunit_completion_php_settings()
    {
        if declare -p _PHPUNIT_COMPLETION_PHP_SETTINGS >/dev/null 2>&1 ; then
            echo "${_PHPUNIT_COMPLETION_PHP_SETTINGS}"
        else
            php -r 'array_map(function($k) { echo $k . PHP_EOL; }, array_keys(ini_get_all(null, false)));' 2>/dev/null
        fi
    }

    _phpunit_completion()
    {
        local phpunit cur prev options

        COMPREPLY=()
        phpunit="${COMP_WORDS[0]}"

        _get_comp_words_by_ref -n '#' cur prev
        cur=$( printf '%q' "${cur}" )
        prev=$( printf '%q' "${prev}" )

        case "${prev}" in
            --coverage-html|--coverage-xml|--include-path|--whitelist)
                _filedir -d 2>/dev/null || COMPREPLY=($(compgen -d -- "${cur}"))
                __ltrim_colon_completions "${cur}"
                return 0
                ;;

            --bootstrap|-c|--configuration|--coverage-*|--log-*|--list-tests-xml|--testdox-*)
                _filedir 2>/dev/null || COMPREPLY=($(compgen -f -- "${cur}"))
                __ltrim_colon_completions "${cur}"
                return 0
                ;;

            --group|--exclude-group)
                options=$(_phpunit_completion_groups "${phpunit}")
                mapfile -t COMPREPLY < <(IFS=$'\n' compgen -W "${options}" -- "${cur}")
                __ltrim_colon_completions "${cur}"
                return 0
                ;;

            --testsuite)
                options=$(_phpunit_completion_suites "${phpunit}")
                mapfile -t COMPREPLY < <(IFS=$'\n' compgen -W "${options}" -- "${cur}")
                __ltrim_colon_completions "${cur}"
                return 0
                ;;

            --filter)
                options=$(_phpunit_completion_tests "${phpunit}")
                mapfile -t COMPREPLY < <(IFS=$'\n' compgen -W "${options}" -- "${cur}")
                __ltrim_colon_completions "${cur}"
                return 0
                ;;

            -d)
                COMPREPLY=($(compgen -W "$(_phpunit_completion_php_settings)" -- "${cur}"))
                __ltrim_colon_completions "${cur}"
                return 0
                ;;

            -h|--help|--list-*|--version)
                __ltrim_colon_completions "${cur}"
                return 0
                ;;

        esac

        if [[ ${cur} == -* ]]; then
            options=$(_phpunit_completion_options "${phpunit}")
            COMPREPLY=($(compgen -W "${options}" -- "${cur}"))
        else
            _filedir 2>/dev/null || COMPREPLY=($(compgen -f -- "${cur}"))
        fi

        __ltrim_colon_completions "${cur}"
        return 0
    }

    _phpunit_completion_detect_phpunit()
    {
        local phpunit
        for phpunit in $( compgen -ca | grep -E '^phpunit' ) ; do
            if [ "${phpunit}" = "phpunit-completion-register" ] ; then
                continue
            fi
            echo "${phpunit}"
        done
    }

    phpunit-completion-register()
    {
        local phpunit commands completion
        commands="${1:-}"
        completion=${2:-_phpunit_completion}
        if [ -z "${commands}" ] ; then
            echo "Missing phpunit commands to register." >&2
            echo "Usage: phpunit-completion-register COMMANDS [FUNCTION]." >&2
            return 1
        fi
        if compgen -A function | grep -q -E "^${completion}$" ; then
            for phpunit in ${commands} ; do
                if [ "${phpunit}" = "phpunit-completion-register" ] ; then
                    continue
                fi
                complete -o bashdefault -F ${completion} "${phpunit}"
            done
            return 0
        else
            echo "Function '${completion}' not found!" >&2
            echo "Failed to register phpunit-bash-completion for '${commands}'." >&2
            return 1
        fi
        return 0
    }

    if [[ $PHPUNIT_COMPLETION_DETECTION = true ]]  ; then
        PHPUNIT_COMPLETION_REGISTER="$PHPUNIT_COMPLETION_REGISTER $(_phpunit_completion_detect_phpunit)"
    fi
    unset PHPUNIT_COMPLETION_DETECTION

    if [ -n "$PHPUNIT_COMPLETION_REGISTER" ]  ; then
        phpunit-completion-register "$PHPUNIT_COMPLETION_REGISTER"
    fi
    unset PHPUNIT_COMPLETION_REGISTER


else

    echo 'phpunit-bash-completion not loaded' >&2
    echo 'It requires bash version >= 3.2 and bash-completion.' >&2
    echo 'For more information, type:' >&2
    echo '' >&2
    echo '    phpunit-completion-help' >&2

    phpunit-completion-help()
    {
        if type -t _get_comp_words_by_ref >/dev/null ; then
            echo 'bash-completion detected!'
            if [ -f "$BASH_SOURCE" ] && source "$BASH_SOURCE" ; then
                unset -f phpunit-completion-help
                echo '"phpunit-bash-completion" has been reloaded.'
                return 0
            else
                echo 'Could not reload "phpunit-bash-completion".' >&2
                echo 'In this case source the "phpunit-completion.bash" again.' >&2
                return 1
            fi
        fi

        echo ''
        echo '"phpunit-bash-completion" requires bash version >= 4.x and'
        echo 'depends on a number of utility functions from "bash-completion".'
        echo ''
        if [ "$(uname -s 2>/dev/null)" = 'Darwin' ] ; then
            if which port &>/dev/null ; then
                echo 'To install "bash-completion" with MacPorts, type:'
                echo ''
                echo '    sudo port install bash-completion'
                echo ''
                echo 'Be sure to add it to your bash startup, as instructed.'
                echo 'Detailed instructions on using MacPorts "bash":'
                echo ''
                echo '    https://trac.macports.org/wiki/howto/bash-completion'
                echo ''
            fi
            if which brew &>/dev/null; then
                echo 'To install "bash-completion" with Homebrew, type:'
                echo ''
                echo '    brew install bash-completion'
                echo ''
                echo 'Be sure to add it to your bash startup, as instructed.'
                echo ''
            fi
        fi
        if which apt-get &>/dev/null; then
            echo 'To install "bash-completion" with APT, type:'
            echo ''
            echo '    sudo apt-get install bash-completion'
            echo ''
        fi
        if which yum &>/dev/null; then
            echo 'To install "bash-completion" with yum, run as root:'
            echo ''
            echo '    yum install bash-completion'
            echo ''
        fi
        echo 'To install bash-completion manually, please see instructions at:'
        echo ''
        echo '    https://github.com/scop/bash-completion#installation'
        echo ''
        echo 'Once bash and bash-completion are installed and loaded,'
        echo 'you may reload phpunit-completion:'
        echo ''
        echo "    source $BASH_SOURCE"
        echo ''
    }

fi
