#!/bin/bash

test_dir=`pwd`/build
repo_path=$test_dir/repo
svn_working_dir=$test_dir/working-copy
trunk_dir=trunk
branches_dir=branches
feature1_branch_dir=branches/feature1
feature2_branch_dir=branches/feature2


function main
{
	init_repo

	feature_update_and_merge_to_trunk "$feature1_branch_dir" "file1.txt" \
		"change1"
	feature_update_and_merge_to_trunk "$feature2_branch_dir" "file2.txt" \
		"change1"

	feature_update_and_merge_to_trunk "$feature1_branch_dir" "file1.txt" \
		"change2"
	feature_update_and_merge_to_trunk "$feature2_branch_dir" "file2.txt" \
		"change2"

	feature_update_and_merge_to_trunk "$feature1_branch_dir" "file1.txt" \
		"change3"
	feature_update_and_merge_to_trunk "$feature2_branch_dir" "file2.txt" \
		"change3"

	# fails to merge: local add, incomming add upon merge.
	#finish_feature_branch "$feature1_branch_dir"
	#finish_feature_branch "$feature2_branch_dir"
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
	create_feature_branches
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
	echo "int main(){ return 0; }" > $main_file
	svn add $main_file
	svn commit -m "Added main.cpp"
	svn up
}


function create_feature_branches
{
	cd $svn_working_dir
	svn cp $trunk_dir $feature1_branch_dir
	svn commit -m "Created feature1 branch off trunk."
	svn up

	cd $svn_working_dir/$feature1_branch_dir
	touch file1.txt
	svn add file1.txt
	svn commit -m "Added file1.txt."


	cd $svn_working_dir
	svn cp $trunk_dir $feature2_branch_dir
	svn commit -m "Created feature2 branch off trunk."
	svn up

	cd $svn_working_dir/$feature2_branch_dir
	touch file2.txt
	svn add file2.txt
	svn commit -m "Added file2.txt."
}


function feature_update_and_merge_to_trunk
{
	feature_branch=$1
	file_name=$2
	change=$3

	cd $svn_working_dir/$feature_branch
	echo "$change" >> $file_name
	svn commit -m "Added change '$change'."

	cd $svn_working_dir
	svn up
	cd $trunk_dir
	svn merge ^/$feature_branch
	svn commit -m "Merged branch $feature_branch."

	cd $svn_working_dir
	svn up
}


function finish_feature_branch
{
	feature_branch_dir=$1

	cd $svn_working_dir/$trunk_dir
	svn merge --reintegrate ^/$feature_branch_dir
	svn commit -m "Merged $feature_branch_dir."

	cd $svn_working_dir
	svn up
	svn rm $feature_branch_dir
	svn commit -m "Removed $feature_branch_dir"
	svn up
}


main
