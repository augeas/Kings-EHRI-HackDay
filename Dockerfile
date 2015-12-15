FROM debian
MAINTAINER Giles Richard Greenway

# Base packages:
RUN apt-get -q -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y --fix-missing install \
        \php5-cli \
        build-essential \
        expect \
        git \
        lynx \
        nano \
        nginx \
        openssh-server \
        php5-common \
        php5-fpm \
        python-dev \
        python-pip \
        python-zmq \
        screen \
        supervisor \
        unzip \
        wget

RUN pip install functools32 jupyter        
        
# Packages needed to build Numpy, Sci-Kit Learn...        
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y --fix-missing install \                
        gfortran \
        gfortran-4.8 \
        libblas-dev \
        libblas3 \
        liblapack-dev \
        liblapack3 \
        libopenblas-base  
       
RUN pip install numpy
RUN pip install scipy
RUN pip install scikit-learn        
RUN pip install nltk
RUN pip install pandas

# Packages needed to build Matplotlib:        
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y --fix-missing install \
        libxft-dev \
        libpng-dev \
        libfreetype6-dev \
        pkg-config

RUN pip install matplotlib

RUN pip install pyldavis lda gensim

RUN git clone https://github.com/ptwobrussell/Mining-the-Social-Web-2nd-Edition.git
#RUN git clone https://github.com/jvns/pandas-cookbook.git

# Misc dependencies for requirements.txt
# Yes, some of the Python modules in the notebooks really want a JVM.
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y --fix-missing install lib32ncurses5-dev \
        openjdk-7-jre-headless

# http://code.google.com/p/fuxi/wiki/Installation_Testing        
RUN pip install http://cheeseshop.python.org/packages/source/p/pyparsing/pyparsing-1.5.5.tar.gz
RUN pip install http://fuxi.googlecode.com/hg/layercake-python.tar.bz2
RUN pip install https://pypi.python.org/packages/source/F/FuXi/FuXi-1.4.1.production.tar.gz        

ADD requirements /
RUN pip install -r /requirements.txt

# Might as well pre-load some of the NLTK resources.
RUN python /preload.py

#RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y --fix-missing install libzmq-dev r-base

ENV USERNAME ehri
ENV PASS ehri
RUN export PASS=ehri && useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USERNAME \
    && echo "$USERNAME:$PASS" | chpasswd 

RUN ln -s /Mining-the-Social-Web-2nd-Edition /home/ehri
#RUN ln -s /pandas-cookbook /home/ehri   
    
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php5/fpm/php-fpm.conf    
    
# http://elfinder.org/    
RUN mkdir -p /var/www/jquery
RUN cd /var/www/jquery/ && wget http://code.jquery.com/jquery-2.1.3.js
RUN cd /var/www && wget http://jqueryui.com/resources/download/jquery-ui-1.11.4.zip \
    && unzip jquery-ui-1.11.4.zip && rm *.zip
RUN mkdir -p /var/www/elfinder && cd /var/www/elfinder && wget http://nao-pon.github.io/elFinder-nightly/latests/elfinder-2.x.zip\
    && unzip elfinder-2.x.zip && rm *.zip
    
ADD nginx /etc/nginx/sites-available
ADD www /var/www 
RUN chmod -R 0755 /var/www     
RUN chmod -R a+rw /home/$USERNAME

RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN mkdir mkdir /var/run/sshd

ADD conf / 
ADD scripts /

CMD /usr/bin/supervisord