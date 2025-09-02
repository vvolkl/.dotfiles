
source ~/.bashrc2
export LC_BASHRC=$LC_BASHRC


xmodmap -e "keycode 66 = Shift_L"

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


#### /keyboard

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#setxkbmap -option caps:escape
#xmodmap -e 'keycode 66 = Mode_switch'
#xmodmap -e 'kkeysym h = h H Left'
#xmodmap -e 'kkeysym l = l L Right'
#xmodmap -e 'kkeysym k = k K Up'
#xmodmap -e 'kkeysym j = j J Down'

#xmodmap ~/.xmodmap
#xcape -e 'Mode_switch=Escape'

# disable capslock without disabling capslock key
#setxkbmap -option 'caps:none'
#xmodmap -e 'keycode 66=Escape'

### bash customizations
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
# bash convenience
export HISTFILESIZE=100000000
export HISTSIZE=100000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"
#if [ -n `command -v gvim` ]; then
#    alias vim='gvim -v'
#fi
set -o emacs

#### set up git prompt and shortcuts

# git stuff
unset SSH_ASKPASS
export SVN_EDITOR=vim
export EDITOR=vim
. ~/.dotfiles/git-completion.bash
. ~/.dotfiles/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\w$(__git_ps1 " (%s)")\$ '

alias xclip="xclip -selection c"



### EOS
export EOSHOME=root://eosuser.cern.ch//eos/user/v/vavolkl/
export EOS_MGM_URL=root://eosuser.cern.ch

#### spack setup
#export SPACK_SKIP_MODULES=yes
#source ~/r/spack/share/spack/setup-env.sh


### shorthands

alias g="grep -I -R --exclude-dir=build* --exclude-dir=install --exclude-dir=.git --exclude-dir=vendor --exclude-dir=externals*"

export gh="https://github.com"
alias lxp='ssh -o StrictHostKeyChecking=no -o GSSAPIAuthentication=yes -o GSSAPITrustDNS=yes -o GSSAPIDelegateCredentials=yes vavolkl@lxplus.cern.ch'
export R=$HOME/repo

alias root='root -l'
alias rootls='rootls -t'

# Add the passed value only to path if it's not already in there.
function add_to_path {
    if [ -z "$1" ] || [[ "$1" == "/lib" ]]; then
        return
    fi
    path_name=${1}
    eval path_value=\$$path_name
    path_prefix=${2}
    case ":$path_value:" in
      *":$path_prefix:"*) :;;        # already there
      *) path_value=${path_prefix}:${path_value};; # or prepend path
    esac
    eval export ${path_name}=${path_value}
}

function spp {
  tmpdir=`mktemp -d`
  cd $tmpdir
  wget $1 
  echo "    patch('$1',
                  sha256='`sha256sum * | cut -d ' ' -f 1`',
                  )
       "
}

function ct {
  IN=$PWD
  arr=$(echo $IN | tr "/" "\n")
  for x in $arr
  do
      if [ -d "${PWD/$x/$1}" ]; then
      cd  ${PWD/$x/$1}
      echo $PWD 
      break
      fi
  done
}


_ct() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--help --verbose --version"
    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    else 
        arr=$(echo $PWD | tr "/" "\n")
        opts1=''
        path1='/'
        for x in $arr
        do
            opts1="$opts1 `ls $path1`"
            path1=$path1$x'/'
        done
        COMPREPLY=( $(compgen -W "${opts1}" -- ${cur}))
        return 0
    fi
}
complete -F _ct ct



#### perl
#PATH="/home/vavolkl/perl5/bin${PATH:+:${PATH}}"; export PATH;
#PERL5LIB="/home/vavolkl/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="/home/vavolkl/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"/home/vavolkl/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/home/vavolkl/perl5"; export PERL_MM_OPT;

add_to_path PATH $HOME/.local/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=:/usr/local/go/bin:$PATH
