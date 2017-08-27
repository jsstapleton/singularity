#!/bin/sh
#Build an environment to create the RPMs for singularity. I picked a junk throw away name.
#All the major work is done in the BUILDING of the IMAGE and not actually from the RUNNING of the image later.
docker build -t sing:junk .

#Now the image exists and has the built RPMs living inside of it.
#We only create a brief running container from this image in order to pull out a few files.
#This method of extraction only works because we are building from a rather full featured base image that includes 
#things like 'tar' and.... 'sh'.  By using the 'sh' inside the container, we can allow it to do the wildcard expansion
#and not need to hardcode the exact names of the RPM package files. So we let 'sh' do the wildcard expansion and then
#stream the tar out of the container and back to us to store in a file back here in the real world.
docker run --rm sing:junk sh -c "tar -cf - *rpm">singularity-rpms.tar

#We don't need to keep the build image around. It was only made to do the work of creating rpms to extract
#If you want to poke around inside the created image, comment out the rmi line below and then step inside the image
#by doing something like
#docker run -it sing:junk /bin/bash
docker rmi sing:junk

#Review the RPMs that were made.
tar -vtf singularity-rpms.tar
