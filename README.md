fmagic_note

Description:

    This is a magic tool, with which you can not only write down and manage
    your notes easily but also search/edit/run them easily.

    You can also use another wrap tool -> magicnote_git to manage your notes, which
    hold in git repository, that may help you sync your notes easier if you prefer to
    use git

DEPENDENCE

    This tool require lua 5.1+

Install:

    ./install.sh
    or
    ./install.sh prefix=/usr/local/

Command:

    bash-$ magicnote
    usage:
      \_ magicnote addsource
      \_ magicnote list [tag1 [ tag2 ...]]
      \_ magicnote add [-tag tagname]
      \_ magicnote rm tag@index [tag2@index2 ...]
      \_ magicnote edit tag@index [tag2@index2 ...]
      \_ magicnote find tag1 tag2 ...
      \_ magicnote run tag@index [tag2@index2 ...]
      \_ magicnote gc

    bash-$ magicnote_git
    usage:
      \_ magicnote addsource source
      \_ magicnote list [tag1 [ tag2 ...]]
      \_ magicnote add [-tag tagname]
      \_ magicnote rm tag@index [tag2@index2 ...]
      \_ magicnote edit tag@index [tag2@index2 ...]
      \_ magicnote find tag1 tag2 ...
      \_ magicnote run tag@index [tag2@index2 ...]
      \_ magicnote status
      \_ magicnote push
      \_ magicnote pull
      \_ magicnote gc

Samples

*addsource*

      bash-$ magicnote addsource

*list*

      bash-$ magicnote list
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
