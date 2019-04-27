# bootstrap fisher if it's not there
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# source aliases
test -f ~/.config/fish/aliases.fish; and . ~/.config/fish/aliases.fish

set -x FZF_DEFAULT_COMMAND 'fd --type f'

# put /usr/local at the front, but not before the anaconda bin
set -x PATH /usr/local/bin $PATH 

set -x JAVA_HOME /Library/Java/JavaVirtualMachines/jdk1.8.0_181.jdk/Contents/Home

set -x PATH /Users/luke/Misc/android/platform-tools $PATH
set -x PATH /Users/luke/.cargo/bin $PATH

set -x KUBECONFIG /Users/luke/cld/ed-infrastructure/kubernetes/staging/eks-config/config-ed-staging.yml

# set up conda. we need to add it to the path manually,
# otherwise you'll have to call `activate' even before
# using conda and python. It's nice to have the root conda
# env running by default.
set -x PATH /Users/luke/anaconda2/bin $PATH 
source (conda info --root)/etc/fish/conf.d/conda.fish

# everything else just bang on the end
#set -x PATH $PATH /Users/luke/.gem/ruby/2.0.0/bin
set -x PATH $PATH /usr/local/sbin
set -x PATH $PATH /Users/luke/bin
#set -x PATH $PATH /Users/luke/Misc/google-cloud-sdk/bin
#set -x PATH $PATH /Users/luke/.npm-packages/bin
#set -x PATH $PATH /Users/luke/Library/Android/sdk/tools
#set -x PATH $PATH /Users/luke/Library/Android/sdk/platform-tools
#set -x PATH $PATH /usr/local/bin
#set -x PATH $PATH /Users/luke/.rvm/bin
#set -x PATH $PATH /Users/luke/.rvm/bin
#set -x PATH $PATH /Users/luke/Misc/apache-maven-3.3.9/bin
#set -x JAVA_HOME /Library/Java/JavaVirtualMachines/jdk1.8.0_40.jdk/Contents/Home

# make this path available to finder launched apps
launchctl setenv PATH $PATH

# fast.ai aliases converted to fish by me
source ~/Projects/fastai-courses/setup/aws-alias.fish
