#!/bin/bash

test_dir=`pwd`/build
repo_path=$test_dir/repo
svn_working_dir=$test_dir/working-copy
trunk_dir=trunk
branches_dir=branches
feature_branch_dir=branches/feature
fix_branch_dir=branches/fix


function main
{
	init_repo
	create_and_merge_branches
}


function init_repo
{
	# Let's create a clean testing repository.
	rm -rf $test_dir
	mkdir -p $test_dir
	svnadmin create $repo_path

	svn checkout file://$repo_path $svn_working_dir

	create_branches_dirs
	add_initial_trunk_commit
}


function create_and_merge_branches
{
	create_feature_branch
	create_main_cpp_fix

	merge_fix_branch_to_feature_branch
	merge_fix_branch_to_trunk

	merge_feature_branch_to_trunk
}


function create_branches_dirs
{
	cd $svn_working_dir
	svn mkdir $trunk_dir
	svn commit -m "Added trunk."

	svn mkdir $branches_dir
	svn commit -m "Added branches directory."
}


function add_initial_trunk_commit
{
	# Add initial implementation of main.cpp - empty file.
	cd $trunk_dir
	main_file=main.cpp
	echo "" > $main_file
	svn add $main_file
	svn commit -m "Added main.cpp"
	svn up
}


function create_feature_branch
{
	cd $svn_working_dir
	svn cp $trunk_dir $feature_branch_dir
	svn commit -m "Created feature branch off trunk."
	svn up

	# Adds readme.
	cd $feature_branch_dir
	readme_file=README.rst
	echo "About" > $readme_file
	svn add $readme_file
	svn commit -m "Added readme."
	svn up
}


function create_main_cpp_fix
{
	cd $svn_working_dir
	svn cp $trunk_dir $fix_branch_dir
	svn commit -m "Created main.cpp fix branch off trunk."
	svn up

	# Fixes main.cpp to have main() function.
	cd $fix_branch_dir
	main_file=main.cpp
	echo "int main() { return 0; }" > $main_file
	svn commit -m "Added main()." $main_file
	svn up
}


function merge_fix_branch_to_feature_branch
{
	cd $svn_working_dir/$feature_branch_dir
	svn merge ^/$fix_branch_dir
	svn commit -m "Merged fix branch to feature branch."
	cd $svn_working_dir
	svn up
}


function merge_fix_branch_to_trunk
{
	cd $svn_working_dir/$trunk_dir
	svn merge ^/$fix_branch_dir
	svn commit -m "Merged fix branch to trunk."
	cd $svn_working_dir
	svn up
}


function merge_feature_branch_to_trunk
{
	cd $svn_working_dir/$trunk_dir
	svn merge --reintegrate ^/$feature_branch_dir
	svn commit -m "Merged feature branch to trunk."
	cd $svn_working_dir
	svn up
}


main
