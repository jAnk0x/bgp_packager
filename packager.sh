#!/bin/bash

# This is the packager for bgp-extrapolator and rov.

# Making sure that jq, python3, and curl are installed
python3_test=$(command -v python3)
jq_test=$(command -v jq)
curl_test=$(command -v curl)
debuild_test=$(command -v debuild)
if [ -z "$python3_test" ]
then
	echo "Aborting: python3 not installed"
	exit 1
fi

if [ -z "$jq_test" ]
then
	echo "Aborting: jq not installed"
	exit 1
fi

if [ -z "$curl_test" ]
then
	echo "Aborting: curl not installed"
	exit 1
fi

if [ -z "$debuild_test" ]
then
	echo "Aborting: debuild not installed (sudo apt-get install devscripts build-essential lintian)"
	exit 1
fi

# Getting forecast release commit shas
fore_rel_sha="$(python3 get_ver.py forecast-sha)"
fore_rel_ver="$(python3 get_ver.py forecast-tag)"
echo "Forcast Release: " $fore_rel_sha
echo "From: "$fore_rel_ver

# Getting forecast nightly commit shas
url_branch='https://api.github.com/repos/c-morris/BGPExtrapolator/branches/master'
fore_night_sha=$(curl -s $url_branch | jq -r '.commit.sha')
fore_night_cut=$(echo $fore_night_sha | cut -c1-7)
echo "Forecast Nightly: " $fore_night_cut

# Get the debian metadata file:
url_branch='https://api.github.com/repos/jAnk0x/BGPExtrapolator-debian-package-metadata/branches/master'
debian_sha=$(curl -s $url_branch | jq -r '.commit.sha')
debian_cut=$(echo $debian_sha | cut -c1-7)
echo "debian metadata: " $debian_cut
# Download it:
dwnload_url=('https://codeload.github.com/jAnk0x/BGPExtrapolator-debian-package-metadata/tar.gz/'$debian_cut)
output_tar=("debian.tar.gz")
output_dir=('debian')
echo "Getting debian from: "$dwnload_url
curl -l $dwnload_url --output $output_tar
mkdir $output_dir && tar -xf $output_tar -C $output_dir --strip-components 2
# Clean up the debian tarball, we don't need it
rm $output_tar
# Save the debian's location for later use
deb=$(pwd)/debian

# Now to download sources and build. We will start with bgp-extrap-release first
dwnload_url=('https://codeload.github.com/c-morris/BGPExtrapolator/tar.gz/'$fore_rel_sha)
# Get the version
ver="$(python3 get_ver.py convert $fore_rel_ver)"
type=('stable')
# Make formatted name for unpacked and packed source
output_tar=('bgp-extrapolator-'$type'_'$ver'.orig.tar.gz')
output_dir=('bgp-extrapolator-'$type'_'$ver)
echo "Getting bgp-extrapolator-stable from: "$dwnload_url
# Make and go into a new dir to save on clutter
mkdir $output_dir && cd $output_dir
# Download the tarball
curl -l $dwnload_url --output $output_tar

# Make a dir for the tarball to extract into and extract
mkdir $output_dir && tar -xf $output_tar -C $output_dir --strip-components 1
# Remove the tarball. We're gonna make a new one later.
rm -r $output_tar

# copy the debian into the new dir
cp -r $deb $output_dir
# cd into directory for building and more work
cd $output_dir

# convert all references to bgp-extrapolator in deb files to bgp-extrapolator-$type
# Fix the makefile
sed -i "s/bgp-extrapolator/bgp-extrapolator-$type/g" Makefile
# Go into the debian folder
cd debian
# Change all folder names
echo "Change folder names"
for file in bgp-extrapolator* ; do mv $file ${file//bgp-extrapolator/bgp-extrapolator-$type} ; done
# Change content within folders to reflect the type
echo "Change file names"
for file in * ; do sed -i "s/bgp-extrapolator/bgp-extrapolator-$type/g" $file ;done #$(find . -maxdepth 1 -type f) ; done 
# Take two steps out to get out of the debian and source
echo "Going out"
cd .. && cd ..

echo "Ouput tar: "$output_tar
echo "Ouput dir: "$output_dir

# Rebuild the tarball
tar -czf $output_tar $output_dir
# Go back into the output dir for building
cd $output_dir
# # Include needed dependencies
# mk-build-deps -i
# Build it
debuild -us -uc
# Get back out into the top level of the packager
cd .. && cd ..

# Now for the forecast nightly
dwnload_url=('https://codeload.github.com/c-morris/BGPExtrapolator/tar.gz/'$fore_night_cut)
type=('unstable')
output_tar=('bgp-extrapolator-'$type'.orig.tar.gz')
output_dir=('bgp-extrapolator-'$type)
echo "Getting bgp-extrapolator-unstable from: "$dwnload_url

# Make and go into a new dir to save on clutter
mkdir $output_dir && cd $output_dir
# Download it
curl -l $dwnload_url --output $output_tar
# Unpack it into a new dir
mkdir $output_dir && tar -xf $output_tar -C $output_dir --strip-components 1
# Remove the tar to rebuild later
rm -r $output_tar
# Copy debian into this new dir
cp -r $deb $output_dir
# Go into the dir
cd $output_dir

# convert all references to bgp-extrapolator in deb files to bgp-extrapolator-$type
# Fix the makefile
sed -i "s/bgp-extrapolator/bgp-extrapolator-$type/g" Makefile
# Go into the debian
cd debian
# change file names to reflect type
for file in bgp-extrapolator* ; do mv $file ${file//bgp-extrapolator/bgp-extrapolator-$type} ; done
# change content in files to reflect type
for file in * ; do sed -i "s/bgp-extrapolator/bgp-extrapolator-$type/g" $file ;done
# Get the version of this nightly release from the changelog
ver=$(grep -o -m 1  '.\..\..' changelog)

# go back to the dir with tarball and unpacked dir
cd .. && cd ..
# rebuild our tarball
tar -czf $output_dir'_'$ver'.orig.tar.gz' $output_dir

# Edit dir and tarball names with the version of the nightly
mv $output_dir $output_dir'_'$ver

# Go into the dir to build
cd $output_dir'_'$ver
# Include needed dependencies
mk-build-deps -i
# Build it
debuild -us -uc

# And now we're done.
