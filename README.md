fmagic_note

Description:

    This is a magic tool, with which you can not only write down and manage
    your notes easily but also search/edit/run them easily.

    You can also use another wrap tool -> magicnote_git to manage your notes, which
    hold in git repository, that may help you sync your notes easier if you prefer to
    use git

DEPENDENCE

    Require Lua 5.1+
    Require Linux or MacOS Operation System

NOTE:

    Better to separate using magicnote and magicnote_git, or your data repository may
    need extra efforts to repair

Install:

    ./install.sh
    or
    ./install.sh prefix=/usr/local/

Command:

    bash-$ magicnote
    usage:
      \_ magicnote addsource
      \_ magicnote ls [-p] [tag1 [ tag2 ...]]
      \_ magicnote add [-t tagname]
      \_ magicnote rm tag@index [tag2@index2 ...]
      \_ magicnote edit tag@index [tag2@index2 ...]
      \_ magicnote find [-p] tag1 tag2 ...
      \_ magicnote run tag@index [tag2@index2 ...]
      \_ magicnote revert
      \_ magicnote show [-v]
      \_ magicnote gc

    bash-$ magicnote_git
    usage:
      \_ magicnote_git addsource source
      \_ magicnote_git ls [-p] [tag1 [ tag2 ...]]
      \_ magicnote_git add [-t tagname]
      \_ magicnote_git rm tag@index [tag2@index2 ...]
      \_ magicnote_git edit tag@index [tag2@index2 ...]
      \_ magicnote_git find [-p] tag1 tag2 ...
      \_ magicnote_git run tag@index [tag2@index2 ...]
      \_ magicnote_git status
      \_ magicnote_git push
      \_ magicnote_git pull
      \_ magicnote_git revert
      \_ magicnote_git show [-v]
      \_ magicnote_git gc

Samples

*addsource*

      bash-$ magicnote addsource

*list*

      bash-$ magicnote ls
      ssh
        |- @1 #1: ssh 127.0.0.1
        |- @2 #1: ssh -P 1234 127.0.0.1

*run*
   
      bash-$ magicnote run ssh@1
      Last login: Mon Dec 17 14:23:10 2012 from localhost
      Property of Final, Inc.
      Unauthorized use prohibited.
      bash:~$ exit
      logout
      Connection to 127.0.0.1 closed.
      bash-$

*find*

      bash-$ magicnote find 1234
      ssh
        |- @2 #1: ssh -P 1234 127.0.0.1
      bash-$ magicnote find 123
      ssh
        |- @2 #1: ssh -P 1234 127.0.0.1
