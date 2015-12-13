# Shortcuts

alias 600="chmod 600"
alias 644="chmod 644"
alias 700="chmod 700"
alias 750="chmod 750"
alias 755="chmod 755"
alias 777="chmod 777"

_ls(){
    clear
    if ls --color > /dev/null 2>&1; then
        # GNU `ls`. Available with `brew install coreutils'.
        ls \
            --almost-all \
            --classify \
            --color=always \
            --group-directories-first \
            --hide-control-chars \
            --human-readable \
            --ignore=*.pyc \
            --ignore=.*.swp \
            --ignore=.DS_Store \
            --ignore=.git \
            --ignore=.hg \
            --ignore=.sass-cache \
            --ignore=.svn \
            --ignore=.swp \
            --literal \
            --time-style=local \
            -X \
            -l \
            -v \
            2> /dev/null

        if [[ $? -ne 0 ]]; then
            ls \
                --almost-all \
                --classify \
                --color=always \
                --hide-control-chars \
                --human-readable \
                --ignore=*.pyc \
                --ignore=.*.swp \
                --ignore=.DS_Store \
                --ignore=.git \
                --ignore=.hg \
                --ignore=.sass-cache \
                --ignore=.svn \
                --ignore=.swp \
                --literal \
                --time-style=local \
                -X \
                -l \
                -v
        fi
    else
        # OS X `ls`
        ls -a -l -F -G
    fi
}

bak() {
    filename="${1}"
    extension=$(basename "${filename##*.}")
    base_filename="${filename%.*}"
    timestamp=$(date +"%Y-%m-%d_%H%I%S")
    new_filename="${base_filename}_${timestamp}.${extension}"
    if [[ ! -f "${new_filename}" ]]; then
        cp -v "${filename}" "${new_filename}"
    else
        echo "destination \"${new_filename}\" exists"
        file "${new_filename}"
    fi
}

alias c="clear"

list_dirstack() {
    i=0
    for dir in $(\dirs -p | awk '!x[$0]++' | head -n 10); do
        echo " ${i}  ${dir}"
        ((i++))
    done
}
alias dirs="list_dirstack"

pushd() {
    if [ "${#}" -eq 0 ]; then
        DIR="${HOME}"
    else
        DIR="${1}"
    fi

    builtin pushd "${DIR}" > /dev/null

    i=0
    for dir in $(\dirs -p | awk '!x[$0]++' | head -n 10); do
        alias -- "${i}"="cd ${dir}"
        ((i++))
    done
}
#alias "cd"="pushd"

edit() {
  editor="${EDITOR}"
  if is_ssh; then
    editor="vim"
  fi
  "${editor}" "${@}"
}
alias e="edit"

_grep() {
    grep \
        --binary-files="without-match" \
        --color \
        --exclude-dir=".git" \
        --exclude-dir=".hg" \
        --exclude-dir=".svn" \
        --line-number \
        "$@"
}
alias grep="_grep"

alias h="history"
alias j="jobs"
alias l="_ls"
alias o="_open"
alias oo="_open ."

fin() {
    terminal-notifier -message "" -title "Done" 2> /dev/null
    if [ $? -eq 127 ]; then
        notify-send --expire-time=1000 "Done $(date)"
    fi
}

case_sensitive_search() {
  if [[ -z "${1}" ]]; then
    return
  fi
  set -x
  grep -R "${1}" . "${@:2}"
  set +x
}
alias s="case_sensitive_search"

case_insensitive_search() {
  if [[ -z "${1}" ]]; then
    return
  fi
  set -x
  grep -Ri "${1}" . "${@:2}"
  set +x
}
alias si="case_insensitive_search"

case_sensitive_search_python() {
  if [[ -z "${1}" ]]; then
    return
  fi
  set -x
  grep -R --include="*.py" "${1}" . "${@:2}"
  set +x
}
alias spy="case_sensitive_search_python"

case_insensitive_search_python() {
  if [[ -z "${1}" ]]; then
    return
  fi
  set -x
  grep -Ri --include="*.py" "${1}" . "${@:2}"
  set +x
}
alias sipy="case_insensitive_search_python"

alias t="tree"

_top() {
    if top -o cpu &> /dev/null; then
        top -o cpu
    else
        top
    fi
}
alias top="_top"

alias addrepo="sudo add-apt-repository"
alias autoclean="sudo apt-get autoclean"
alias autoremove="sudo apt-get autoremove"
alias clean="sudo apt-get clean"
alias distupgrade="sudo apt-get dist-upgrade"
alias upgrade="sudo apt-get upgrade"
alias x="exit"
alias q="exit"
alias reboot="sudo shutdown -r now"

_open() {
    open "$@" &> /dev/null
    if [ ! $? -eq 0 ]; then
        nautilus "$@"
    fi
}

_ip() {
    if [ -x /sbin/ifconfig ]; then
        /sbin/ifconfig
    else
        ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //' | sort | sed 's/\('$(ipconfig getifaddr en1)'\)/\1 [LOCAL]/'
    fi
}
alias ip="_ip"

clipboard() {
    # Remove trailing newline from stdin and copy it to the clipboard.
    if which "xsel" &> /dev/null; then
        perl -p -e 'chomp if eof' | xsel --clipboard
    elif which "pbcopy" &> /dev/null; then
        perl -p -e 'chomp if eof' | pbcopy
    fi
}
alias clip="clipboard"
alias copy="clipboard"

alias dotfiles="dotstar"
alias dotstar="cd ${HOME}/.dot-star && l"
alias .*="dotstar"
alias extra="vim ${HOME}/.dot-star/bash/extra.sh"
alias hosts="sudo vim /etc/hosts"
alias known_hosts="vim ${HOME}/.ssh/known_hosts"
alias sshconfig="vim ${HOME}/.ssh/config"

alias aliases="vim ${HOME}/.dot-star/bash/.aliases.sh"
alias bashprofile="vim ${HOME}/.bash_profile"
alias bashrc="vim ${HOME}/.bashrc"
alias +x="chmod +x"

large_files() {
    du -hs * | sort -h
}
alias large="large_files"

slugify() {
    cat <<EOF | python -
import re
value = re.sub('[^\w\s\.-]', '', '${1}').strip().lower()
print re.sub('[-\s]+', '-', value)
EOF
}
alias slug="slugify"

slugify_mv() {
    for filename in "${@}"; do
        new_filename=$(slugify "${filename}")
        if [[ "${new_filename}" != "${filename}" ]]; then
            message='Rename "'${filename}'" to "'${new_filename}'"?'
            read -p "${message} [y/n] " -n 1 -r; echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                mv "${filename}" "${new_filename}"
            fi
        else
            echo "${filename} OK"
        fi
    done
}
alias smv="slugify_mv"

pdf_remove_password() {
    green=$(tput setaf 64)
    red=$(tput setaf 124)
    read password
    in="${1}"
    out=$(echo "${in}" | perl -pe 's/^(.*)(\.pdf)$/\1_passwordless.pdf/')
    qpdf --decrypt --password="${password}" "${in}" "${out}"
    if [[ $? -eq 0 ]]; then
        echo -e "${red}- ${in}"
        echo -e "${green}+ ${out}"
        # rm -v "${in}"
    fi
}

change_mac_address() {
    current_mac_address=$(ifconfig en0 | \grep ether | perl -pe 's/^\s+ether (.*) /\1/')
    echo -e "\033[31m-${current_mac_address}\033[0m"

    new_mac_address=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
    echo -e "\033[32m+${new_mac_address}\033[0m"

    sudo ifconfig en0 ether "${new_mac_address}"

    current_mac_address=$(ifconfig en0 | \grep ether | perl -pe 's/^\s+ether (.*) /\1/')
    if ! [[ $new_mac_address == $current_mac_address ]]; then
        echo "DIFFERENCE FOUND"
        echo "expected ${new_mac_address}"
        echo "got      ${current_mac_address}"
    fi

    sudo ifconfig en0 down
    sudo ifconfig en0 up
}

difference() {
    command="diff -u ${1} ${2} | colordiff | less -R"
    echo "${command}"
    eval $command
}
alias d="difference"

chmod() {
    if [ "$#" -eq 1 ]; then
        file_mode_bits=$(stat --format "%a" "${1}")
        echo -e "${file_mode_bits}\t${1}"
    else
        command chmod "${@}"
    fi
}

f() {
    # Find files with path containing the specified keyword.
    keyword="${1}"
    if [[ -z "${keyword}" ]] ; then
        echo "Search is empty"
    else
        echo "Searching for files with path containing \"*${keyword}*\":" | \grep --color --ignore-case "${keyword}"
        find . -type f -iname "*${keyword}*" | \grep --color --ignore-case "${keyword}"
    fi
}


un() {
    command=$(cat <<EOF | python -
import os

filename = '${1}'
command = ''
if filename.endswith('.zip'):
    command = 'unzip'
elif filename.endswith(('.tar.bz2', '.tar.gz',)):
    command = 'tar xvf'
if command:
    print command
EOF)
    if [ ! -z "${command}" ]; then
        echo "command: ${command}"
        ${command} ${1}
    fi
}

type() {
    if [ ! -z "${1}" ]; then
        response=$(command type "${1}")
        echo "${response}"
        command=$(cat <<EOF | python -
import re

match = re.match(r".* is aliased to \`([\w]+)'", """${response}""")
if match is not None:
    print 'type {0}'.format(match.group(1))
EOF
)
        if [ ! -z "${command}" ]; then
            ${command}
        fi
    fi
}
alias ty="type"

is_ssh() {
    if [ -z "${SSH_CLIENT}" ]; then
        return 1
    fi
    return 0
}
