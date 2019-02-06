FROM ubuntu:14.04


# Preparation
RUN apt-get update

# Install server dependencies
RUN apt-get install -y curl git git-core python-virtualenv gcc python-pip python-dev libjpeg-turbo8 libjpeg-turbo8-dev zlib1g-dev libldap2-dev libsasl2-dev swig libxslt-dev automake autoconf libtool libffi-dev libcairo2-dev libssl-dev
RUN pip install virtualenv --upgrade

# Install database
RUN apt-get install -y software-properties-common
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/5.5/ubuntu trusty main'
RUN apt-get install -y mariadb-server mariadb-client libmariadbclient-dev libmariadbd-dev

# Install UI dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y nodejs

# Cleaning
RUN apt-get clean
RUN apt-get purge

ADD settings_local.py /root/settings_local.py

# Install the backend
RUN mkdir ~/badgr \
  && cd ~/badgr \
  && virtualenv env \
  && /bin/bash -c "source env/bin/activate" \
  && git clone https://github.com/concentricsky/badgr-server.git code \
  && cd code \
  && pip install -r requirements.txt \
  && cp /root/settings_local.py apps/mainsite/


RUN cd ~/badgr/code  \
  && ./manage.py migrate \
  && ./manage.py dist

# # Start the server
RUN ./manage.py runserver

# Install the frontend
RUN cd ~
RUN git clone https://github.com/concentricsky/badgr-ui.git badgr-ui \
  && cd badgr-ui \
  && npm install

# # Start the froentend
RUN npm run start
RUN cd ..

EXPOSE 8000
EXPOSE 4200