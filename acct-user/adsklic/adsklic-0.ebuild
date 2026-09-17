EAPI=8
inherit acct-user
DESCRIPTION="Autodesk Licensing service user"
ACCT_USER_ID=498
ACCT_USER_GROUPS=( adsklic )
ACCT_USER_HOME=/var/empty
ACCT_USER_HOME_PERMS=0750
acct-user_add_deps
