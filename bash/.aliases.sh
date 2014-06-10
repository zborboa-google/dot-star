# Shortcuts

_ls(){
    clear
    if ls --color > /dev/null 2>&1; then
        # GNU `ls`
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
    extension="${filename##*.}"
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
alias "cd"="pushd"

_grep() {
    grep \
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

_search_text() {
    case_sensitive=$1
    if $case_sensitive; then
      grep -R "${2}" .
    else
      grep -Ri "${2}" .
    fi
}
alias s="_search_text true"
alias si="_search_text false"

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

alias dotfiles="dotstar"
alias dotstar="cd ${HOME}/.dot-star && l"
alias extra="vim ${HOME}/.dot-star/bash/extra.sh"
alias sshconfig="vim ${HOME}/.ssh/config"

alias bashprofile="vim ${HOME}/.bash_profile"
alias bashrc="vim ${HOME}/.bashrc"

export ssh=false
if [ ! -z "$SSH_CONNECTION" ]; then
  ssh=true
fi
