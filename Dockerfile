FROM centos:centos6.7
MAINTAINER enzo smartinsightsfromdata 

RUN yum -y install epel-release
RUN yum update -y && yum clean all
RUN yum reinstall -y glibc-common
RUN yum install -y locales java-1.7.0-openjdk-devel tar

# Misc packages

RUN yum groupinstall -y "Development Tools" 
RUN yum install -y rsyslog wget sudo git passwd

WORKDIR /home/root
RUN yum install -y R

RUN wget http://cran.r-project.org/src/contrib/rJava_0.9-7.tar.gz
RUN R CMD INSTALL rJava_0.9-7.tar.gz
RUN R CMD javareconf \
	&& rm -rf rJava_0.9-7.tar.gz

#-----------------------

# Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin/:$PATH 
ENV LANG en_US.UTF-8

RUN yum install -y openssl098e supervisor pandoc
RUN wget http://download2.rstudio.org/rstudio-server-rhel-0.99.484-x86_64.rpm
RUN yum -y install --nogpgcheck rstudio-server-rhel-0.99.484-x86_64.rpm
RUN rm -rf rstudio-server-rhel-0.99.484-x86_64.rpm

RUN groupadd rstudio \
	&& useradd -g rstudio rstudio \
	&& echo rstudio | passwd rstudio --stdin 

RUN wget https://download3.rstudio.org/centos5.9/x86_64/shiny-server-1.4.0.721-rh5-x86_64.rpm
RUN yum -y install --nogpgcheck shiny-server-1.4.0.721-rh5-x86_64.rpm
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='http://cran.r-project.org', INSTALL_opts='--no-html')" \
&& rm -rf shiny-server-1.4.0.721-rh5-x86_64.rpm

RUN mkdir -p /var/log/shiny-server \
	&& chown shiny:shiny /var/log/shiny-server \
	&& chown shiny:shiny -R /srv/shiny-server \
	&& chmod 777 -R /srv/shiny-server \
	&& chown shiny:shiny -R /opt/shiny-server/samples/sample-apps \
	&& chmod 777 -R /opt/shiny-server/samples/sample-apps 

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor \
	&& chmod 777 -R /var/log/supervisor


EXPOSE 8787 3838

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 
