(
  printf "Install Oracle"

  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && |
  apt-get -y install oracle-java8-installer 
) && echo "PASS" || echo "FAIL"


(
  printf "Install ElasticSearch"

  wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
  echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a
  /etc/apt/sources.list.d/elasticsearch-2.x.list && \
  apt-get update && \
  apt-get -y install elasticsearch  && \
  service elasticsearch restart && \
  update-rc.d elasticsearch defaults 95 10
) && echo "PASS" || echo "FAIL"

(
  printf "Install Kibana""

  echo "deb http://packages.elastic.co/kibana/4.4/debian stable main" | tee -a /etc/apt/sources.list.d/kibana-4.4.x.list
  apt-get update && \
  apt-get -y install kibana && \
  update-rc.d kibana defaults 96 9 && \
  service kibana start
) && echo "PASS" || echo "FAIL"


(
  apt-get install nginx apache2-utils && \
  htpasswd -c /etc/nginx/htpasswd.users kibanaadmin && \
  cat <<EOF > /etc/nginx/sites-available/default
server {
  listen 80;

  server_name example.com;

  auth_basic "Restricted Access";
  auth_basic_user_file /etc/nginx/htpasswd.users;

  location / {
    proxy_pass http://localhost:5601;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;        
  }
EOF
  [ $? -eq 0 ] && service nginx restart
) && echo "PASS" || echo "FAIL"





