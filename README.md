# bgp_packager
Packager for c-morris/BGPExtrapolator. Please see the README at that repository for instructions on application use.
The scripts in this repository will download from c-morris/BGPExtrapolator the most recent releases of rov++ and BGPExtrapolator, and their respective unstable versions.

# Using the packager
To use the packager, download the Bash and Python scripts in this repository and place them in the directory you want the packages to go in. You must also have python3, curl, and jq installed on your machine.
Then, in the directory, chmod packager.sh if necessary, and simply do the following:

  ```
  sudo ./packager.sh
  ```

This will then download and package 4 versions of c-morris/BGPExtrapolator:
- The release and unstable (from branch master) versions of BGPExtrapolator 
- The release and unstable (from branch rovpp2) versions of rovpp2

The packager will also make a directory for each individual version and package using debuild within the version's respective folder.

# Installation of packages
To install the packages after packaging, navigate to the desired package's folder, and do:
```
sudo dpkg -i bgp-extrapolator-<type>_<version>_amd64.deb
```
or
```
sudo dpkg -i rov-<type>_<version>_amd64.deb
```
for rov packages.
After installing all four packages, they can be called from the command line with:
```
bgp-extrapolator-stable
bgp-extrapolator-unstable
rov-stable
rov-unstable
```

# Caveats
The script makes several requests to the Github REST API. If the standard rate limit of 60 unauthenticated requests are nearly reached or have been reached before using the script, the script may fail to work. Please wait an hour before trying again so that the limit resets.

# Version syntax
The tag for releases must be in the form:
```
bgpe-v#.#.# // For BGPExtrapolator releases
rov-v#.#.# // For ROV releases
```
Deviations from this will break get_ver.py.
