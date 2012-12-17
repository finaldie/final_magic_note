fmagic_note

Description:

    This is a magic tool, with which you can not only write down and manage
    your notes easily but also search/edit/run them easily.

Install:

    ./install.sh
    or
    ./install.sh prefix=/usr/local/

Command:

    bash-$ magicnote
    usage:
      \_ magicnote addsource source
      \_ magicnote list [tag1 [ tag2 ...]]
      \_ magicnote add [-tag tagname]
      \_ magicnote rm tag@index [tag2@index2 ...]
      \_ magicnote edit tag@index [tag2@index2 ...]
      \_ magicnote find tag1 tag2 ...
      \_ magicnote run tag@index [tag2@index2 ...]

Samples

*addsource*
    
      bash-$ magicnote addsource git@github.com:username/magic_note.git
      Cloning into '/xxx/magicnote/var/magicnote/main'...
      remote: Counting objects: 3, done.
      remote: Total 3 (delta 0), reused 0 (delta 0)
      Receiving objects: 100% (3/3), done.
      [master aa0fb63] create index
      0 files changed
      create mode 100644 index

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
