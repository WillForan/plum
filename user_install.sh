#!/usr/bin/env sh

# which rc file should we use?
# ~/.zshrc, ~/.bashrc, ~/.profile 
# N.B. fish not supported
find_rc() {
   shell=`basename $SHELL`
   if [ "$shell" = "zsh" ]; then
      rc=$HOME/.zshrc
   elif [ "$shell" = "bash" ]; then
      for f in $HOME/.{profile,bashrc}; do
         [ -r $f ] && rc=$f && continue
      done
   else
      echo "shell ('$SHELL') is not bash or zsh. install panics" >&2
      return 1
   fi

   [ -r "$rc" ] && echo "$rc" || return 1
}

# clone plumb and add to path
get_plum(){
   rc=`find_rc`
   [ -z "$rc" ] && return 1

   [ ! -d plum ] &&
     git clone 'https://raw.githubusercontent.com/WillForan/plum'

   ! egrep "PATH=.*$PWD/plum" $rc >/dev/null &&
     echo "export PATH=\$PATH:$PWD/plum" >> $rc
}

# add escape sequence to prompt command/precomand to set x11 title of shell
add_title() {
   rc=`find_rc`
   [ -z "$rc" ] && return 1

   if [ $(basename $rc) = .zshrc ]; then
      # is zsh

      grep precmd $rc && 
         echo "not overwritting your prompt command" &&
         return 1

      cat <<-EOF | sed 's/^\t\t//' >> $rc
		function precmd () {
		  window_title="\033]0;\$USER@\$HOSTNAME:\${PWD}\007"
		  echo -ne "\$window_title"
		}
		EOF

   else
      # is bash
      grep PROMPT_COMMAND $rc && 
         echo "not overwritting your prompt command" &&
         return 1
      cat <<EOF >> $rc
  export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
EOF
   fi
}

get_plum
add_title
