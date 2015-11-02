# Ubuntu latest
# Oracle Java 1.8.0_65 64 bit
# Maven 3.3.3
# OpenSSH latest

# extend the most recent long term support Ubuntu version
FROM ubuntu:latest

MAINTAINER jack "askfish@gmail.com"

# update dpkg repositories
RUN apt-get update

# install wget
RUN apt-get install -y wget

# get maven 3.3.3
RUN wget --no-verbose -O /tmp/apache-maven-3.3.3.tar.gz http://archive.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz

# verify checksum
RUN echo "794b3b7961200c542a7292682d21ba36 /tmp/apache-maven-3.3.3.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.3.3.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.3.3 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.3.3.tar.gz
ENV MAVEN_HOME /opt/maven


#install java
#RUN apt-get install -y default-jdk

# remove download archive files
RUN apt-get clean

# set shell variables for java installation
ENV java_version 1.8.0_65
ENV filename jdk-8u65-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u65-b17/$filename

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# Copy source to docker vm
ADD ssh/ /opt/ssh-script/

# Install OpenSSH
RUN apt-get install -y openssh-server

# configure the container to run weixn
ENTRYPOINT /opt/ssh-script/run.sh

# Expose SSH port
EXPOSE 22

