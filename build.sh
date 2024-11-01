#! /bin/bash

RC=0
WORKDIR=/source

LOCKFILE=${WORKDIR}/.lock

GPG_PRIVATE_KEY_NAME="${INPUT_SIGNING_KEY_NAME}"
GPG_PRIVATE_KEY_FILE="${INPUT_SIGNING_KEY_FILE}"

if [ -f ${LOCKFILE} ]
then
  count=0
  waittime=20
  while [ $count -lt 10 -a -f $LOCKFILE ]
  do
    echo "::notice title=RPMbuild::Lock file found, waiting ${waittime}s"
    sleep $waittime
    count=$((count + 1))
  done
  if [ -f ${LOCKFILE}]
  then
    echo "::error title=RPMbuild::Lock still present, aborting."
    exit 127
  fi
fi

touch $LOCKFILE

pwd

mkdir -p ${WORKDIR}/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
RC=$(($RC + $? ))

if [ $RC -eq 0 ]
then
  echo "Source repository directory is: ${WORKDIR}/${INPUT_SOURCE_REPO_LOCATION}"
  echo "::notice title=RPMbuild::Source repository directory is ${WORKDIR}/${INPUT_SOURCE_REPO_LOCATION}"

  # Check that at least one SPEC file exists
  ls ${WORKDIR}/${INPUT_SOURCE_REPO_LOCATION}/${INPUT_SPEC_FILE_LOCATION}/*.spec
  RC=$(($RC + $? ))

  if [ $RC -eq 0 ]
  then
    echo "::notice title=RPMbuild::Source repository directory is ${WORKDIR}/${INPUT_SOURCE_REPO_LOCATION}"

    declare $(rpm -q --qf "%{V}\n" selinux-policy | awk -F '.' '{ major=$1; minor=$2 } END { if( major*minor==0) {print "_sepol_minver_cond=0" ; print "_sepol_maxver_cond=0"} else {print "_sepol_minver_cond="major"."minor; print "_sepol_maxver_cond="major"."(minor+1)}}')

    if [ "${_sepol_minver_cond}" != "0" -a "${_sepol_maxver_cond}" != "0" ]
    then
      for specfile in ${WORKDIR}/${INPUT_SOURCE_REPO_LOCATION}/${INPUT_SPEC_FILE_LOCATION}/*.spec
      do
        /usr/bin/rpmbuild -bb \
          --define="_topdir ${WORKDIR}/rpmbuild" \
          --define="_builddir ${WORKDIR}/${INPUT_SOURCE_REPO_LOCATION}" \
          --define="_provided_version ${INPUT_PROVIDED_VERSION:-null}" \
          --define="_provided_release ${INPUT_PROVIDED_RELEASE:-null}" \
          --define="_sepol_minver_cond >= ${_sepol_minver_cond}" \
          --define="_sepol_maxver_cond <= ${_sepol_maxver_cond}" \
          ${specfile}
        rc=$?
        RC=$(( $RC + $rc ))
        [ $rc -ne 0 ] && echo "::error title=RPMbuild::Could not build RPM for spec file ${specfile}."
      done
    else
      echo "::error title=RPMbuild::Could not define selinux-policy version requirements"
    fi      
  else
    echo "::error title=RPMbuild::Could not find RPM spec file in ${WORKDIR}/${INPUT_SOURCE_REPO_LOCATION}/${INPUT_SPEC_FILE_LOCATION}/"
  fi

  #Signing all rpms that were created
  if [ $RC -eq 0 ] 
  then
    gpg --batch  --passphrase-file ${WORKDIR}/.${GPG_PRIVATE_KEY_FILE}.passphrase --import ${WORKDIR}/${GPG_PRIVATE_KEY_FILE}
    rc1=$?
    [ $rc1 -ne 0 ] && echo "::error title=RPMbuild::Could not import private key."

    export GPG_TTY=$(tty)
    rpmsign --define="_gpg_name ${GPG_PRIVATE_KEY_NAME}" \
      --define="_gpg_sign_cmd_extra_args --batch --passphrase-file ${WORKDIR}/.${GPG_PRIVATE_KEY_FILE}.passphrase --pinentry-mode loopback" \
      --addsign ${WORKDIR}/rpmbuild/RPMS/*/*.rpm
    rc2=$?
    [ $rc2 -ne 0 ] && echo "::error title=RPMbuild::Could not sign the RPMs that were previously generated."
    rpm -qpi ${WORKDIR}/rpmbuild/RPMS/*/*.rpm | grep ^Sign
    rc2=$(( $rc2 + $? ))

    RC=$(( $RC + $rc1 + $rc2 ))
  fi
else
  echo "::error title=RPMbuild::Unable to create directories under ${WORKDIR}"
fi

rm -f $LOCKFILE

exit $RC