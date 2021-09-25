git add file_name -v # 新建一个文件时，让 git 追踪这个文件
                     # 可以使用 *.py 表示所有以 .py 结尾的文件
                     # v表示 verbose，输出详细信息
git add -uv          # 更改 git 正在追踪文件后，告诉 git 我更新了
                     # u表示只更新正在追踪的文件
                     # 与之相对的，网上教的 `git add .` 就会把当前文件夹下所有乱七八糟的东西，log啊，__pycache__啊，都加进去，非常不优雅
git commit           # git add 之后，告诉 git 我确认这些更改没问题
git push             # git commit 之后，告诉 git 推到 github 上
git pull             # github 有更新，拉取到本地

# 例：
# 某人新建了这个 git_tutorial.sh，那他第一次上传要依次用如下命令

git add git_tutorial.sh -v
git commit
git push

# 之后他更新这个文件再上传需要用如下命令

git add -uv
git commit
git push

# Git Multi-branch

* show git branches `git branch`, the one with asterisk is the current branch.
* create new branch `git branch branchname`
* switch to branch  `git checkout branchname`
* create new branch b2 on github based on local branch b1 `git push --set-upstream origin b1:b2`, b1 and b2 can have the same name