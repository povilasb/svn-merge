=====
About
=====

This repo contains scripts to demonstrate some simplified scenarios when svn
fails to merge. During the casual work with svn sometimes I get into situations
"What is happening?". With these mini scripts I'll try to recreate some
weird merging behavior and understand what is happening.

All tests were executed with svn 1.7.18 version on Debian 7 system.


Prerequisites
=============

* subversion (installation script on Debian systems:
  https://github.com/povilasb/unix-configs/tree/master/svn).


merge_same_revisions.sh
=======================

This script creates a testing repository with three branches: trunk, feature
and fix. All commits are made in such sequence:

#. root: create trunk directory.
#. root: create branches/feature directory.
#. trunk: add initial main.cpp.
#. root: create feature branch.
#. feature branch: add README.rst.
#. root: create fix branch.
#. fix branch: fix main.cpp implementation.
#. feature branch: merge fix branch.
#. trunk: merge fix branch.
#. trunk: merge feature branch.

::

	root dir    trunk      feature       fix

	R1--o--------o
	    |        |
	R2--o        |
	         R3--o--branch-->-o--R4
	             |            |
	             |        R5--o
	             |            |
	             ---branch-->--------------o--R6
	             |            |            |
	             |            |------------o--R7
	             |            |            |
	             |        R8--o--<--merge--|
	             |            |            |
	         R9--o-------<--merge-----------
	             |            |
	        R10--o--<--merge---


Actually this little scenario merges both branches to trunk without any
conflicts.
