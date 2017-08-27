# Start with a clean base images of centos 7
FROM centos:7
#Freshen this base. This may include updates to rpm DBs and such as well as updates to yum itself so get it out of the way
RUN yum update -y
#Bring in a glob of tools used to build software
RUN yum groupinstall -y "Development Tools"
#You can put the software we are about to fetch for singularity anywhere and even be tidy about it but this whole
#process is just to create a build and throw away image.
#So here we just sloppily put the git cloned software right at the top of the virtual file system
WORKDIR /
#git was included in the Development Tools. I built the following steps based on instructions here:
# http://singularity.lbl.gov/admin-guide
#But also I took a peek at the INSTALL.md file inside the software directory
RUN git clone https://github.com/singularityware/singularity.git
#Pop inside the newly created clone directory
WORKDIR singularity
#Do steps from the docs to build the software
RUN ./autogen.sh
RUN ./configure
RUN make dist
#Here I set an environment variable to use as a way to point the rpms to build in /opt/singularity
#This can also be done better as a parameter that can be passed in during build instead of hardcoding it.
ENV PREFIX /opt/singularity
#Make rpms as outlined in docs.
RUN rpmbuild -ta --define="_prefix $PREFIX" --define "_sysconfdir $PREFIX/etc" --define "_defaultdocdir $PREFIX/share" singularity*.tar.gz 
#By watching the process run to completion once, I was able to locate the target directory where the rpms are stored after
#creation. I move the CWD to this location so the rpms are under an invoker's fingertips.
WORKDIR /root/rpmbuild/RPMS/x86_64
#RUN cp singularity*rpm /
