#!/bin/bash

curr_dir=`dirname $0`
curr_dir=`cd $curr_dir; pwd`

setup_host="$curr_dir/setup_host.sh"
# Define your application/component name here.
# Define the version of your component in setup_env.sh
yourcomponent=apache-maven
yourcomponent_spec="$curr_dir/${yourcomponent}.spec"
mock_cfg="$curr_dir/altiscale-maven-centos-6-x86_64.cfg"
mock_cfg_name=$(basename "$mock_cfg")
mock_cfg_runtime=`echo $mock_cfg_name | sed "s/.cfg/.runtime.cfg/"`

maven_zip_file="$WORKSPACE/${YOURCOMPONENT}-${YOURCOMPONENT_VERSION}.tar.gz"
maven_url="http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/${YOURCOMPONENT_VERSION}/binaries/${YOURCOMPONENT}-${YOURCOMPONENT_VERSION}-bin.tar.gz"

if [ -f "$curr_dir/setup_env.sh" ]; then
  source "$curr_dir/setup_env.sh"
fi

# Update variables
maven_zip_file="$WORKSPACE/${YOURCOMPONENT}-${YOURCOMPONENT_VERSION}.tar.gz"
maven_url="http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/${YOURCOMPONENT_VERSION}/binaries/${YOURCOMPONENT}-${YOURCOMPONENT_VERSION}-bin.tar.gz"

if [ "x${YOURCOMPONENT}" = "x" ] ; then
  yourcomponent=example
  echo "ok - you may want to define your component name in setup_env.sh with YOUCOMPONENT variable, and set it global during the build process"
else
  yourcomponent="$YOURCOMPONENT"
fi

echo "ok - building component $yourcomponent"

if [ "x${WORKSPACE}" = "x" ] ; then
  WORKSPACE="$curr_dir/../"
  maven_zip_file="$WORKSPACE/${YOURCOMPONENT}-${YOURCOMPONENT_VERSION}.tar.gz"
fi

# Perform sanity check
if [ ! -f "$curr_dir/setup_host.sh" ]; then
  echo "warn - $setup_host does not exist, we may not need this if all the libs and RPMs are pre-installed in your build environment"
fi

if [ ! -e "$yourcomponent_spec" ] ; then
  echo "fail - missing $yourcomponent_spec file, can't continue, exiting"
  exit -9
fi

env | sort
# should switch to WORKSPACE, current folder will be in WORKSPACE/yourcomponent due to 
# hadoop_ecosystem_component_build.rb => this script will change directory into your submodule dir
# WORKSPACE is the default path when jenkin launches e.g. /mnt/ebs1/jenkins/workspace/yourcomponent_build_test-alee
# If not, you will be in the $WORKSPACE/yourcomponent folder already, just go ahead and work on the submodule
# The path in the following is all relative, if the parent jenkin config is changed, things may break here.
pushd `pwd`
cd $WORKSPACE

if [ -f "$maven_zip_file" ] ; then
  fhash=$(md5sum "$maven_zip_file" | cut -d" " -f1)
  if [ "x${fhash}" = "xaaef971206104e04e21a3b580d9634fe" ] ; then
    echo "ok - found prev downloaded file, hash looks good, use it directly"
  else
    echo "warn - maven.tar.gz corrupted with $fhash <> aaef971206104e04e21a3b580d9634fe, re-downloading"
    wget --output-document=$(basename $maven_zip_file) "$maven_url"
  fi
else
  echo "ok - downloading maven.tar.gz"
  wget --output-document=$(basename $maven_zip_file) "$maven_url"
fi
# Only applies to Boost installation, delete previous installationif exist.
# This machine shouldn't have existing maven instllation.
if [ -d $WORKSPACE/${YOURCOMPONENT}-${YOURCOMPONENT_VERSION}/ ] ; then
  echo "warn - uninstalling previous version of Boost"
fi
#tar -xzf 
#mv maven_* apache-maven
popd

echo "ok - tar zip source file, preparing for build/compile by rpmbuild"
pushd `pwd`
# yourcomponent is located at $WORKSPACE/$yourcomponent
cd $WORKSPACE

# If you are using the %setup stage, you may need to tarzip your source code here and copy it to the $WORKSPACE/rpmbuild/SOURCES folder later.
# Renaming the folder with prefix alti- here as well.
# cp -r "$yourcomponent" "alti-${yourcomponent}"
# tar cvzf $WORKSPACE/alti-${yourcomponent}.tar.gz "alti-${yourcomponent}"

mkdir -p $WORKSPACE/rpmbuild/{BUILD,BUILDROOT,RPMS,SPECS,SOURCES,SRPMS}/
cp "$yourcomponent_spec" $WORKSPACE/rpmbuild/SPECS/$yourcomponent.spec

# If you are only applying the %prep stage, you can manually copy the folders you need.

# Otherwise, if you are using %setup, you may want to copy the tar.gz created before
cp -r "$maven_zip_file" $WORKSPACE/rpmbuild/SOURCES/

# Explicitly define IMPALA_HOME here for build purpose
echo "ok - applying version number $YOURCOMPONENT_VERSION and release number $BUILD_TIME"
sed -i "s/YOURCOMPONENT_VERSION/$YOURCOMPONENT_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/$yourcomponent.spec"
sed -i "s/BUILD_TIME/$BUILD_TIME/g" "$WORKSPACE/rpmbuild/SPECS/$yourcomponent.spec"
rpmbuild -vv -bs $WORKSPACE/rpmbuild/SPECS/$yourcomponent.spec \
         --define "_topdir $WORKSPACE/rpmbuild"

if [ $? -ne "0" ] ; then
  echo "fail - SRPM build for $yourcomponent.src.rpm failed"
  exit -8
fi

mkdir -p "$WORKSPACE/var/lib/mock"
chmod 2755 "$WORKSPACE/var/lib/mock"
mkdir -p "$WORKSPACE/var/cache/mock"
chmod 2755 "$WORKSPACE/var/cache/mock"
sed "s:BASEDIR:$WORKSPACE:g" "$mock_cfg" > "$curr_dir/$mock_cfg_runtime"
sed -i "s:YOURCOMPONENT_VERSION:$YOURCOMPONENT_VERSION:g" "$curr_dir/$mock_cfg_runtime"
echo "ok - applying mock config $curr_dir/$mock_cfg_runtime"
cat "$curr_dir/$mock_cfg_runtime"
mock -vvv --configdir=$curr_dir -r altiscale-maven-centos-6-x86_64.runtime \
          --resultdir=$WORKSPACE/rpmbuild/RPMS/ \
          --rebuild $WORKSPACE/rpmbuild/SRPMS/$yourcomponent-$YOURCOMPONENT_VERSION-*.src.rpm

if [ $? -ne "0" ] ; then
  echo "fail - mock RPM build for $yourcomponent failed"
  #mock --configdir=$curr_dir -r altiscale-maven-centos-6-x86_64.runtime --clean
  mock --configdir=$curr_dir -r altiscale-maven-centos-6-x86_64.runtime --scrub=all
  exit -9
fi

#mock --configdir=$curr_dir -r altiscale-maven-centos-6-x86_64.runtime --clean
mock --configdir=$curr_dir -r altiscale-maven-centos-6-x86_64.runtime --scrub=all

popd

echo "ok - build Completed successfully!"

exit 0












