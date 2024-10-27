#Aquí se marca la imagen  que será la base de docker que se usará la cual es ubuntu en su versión 20.04
FROM ubuntu:20.04

#Este paso realiza la operación de corrido sin que al momento de instalarse se detenga esperando alguna intervensión del
#usuario, ya que mayormente solicita la zona geográfica para realizar su configuración, con este paso se salta esa parte
#y el usuario no podrá interactuar
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza la lista de paquetes e instala los paquetes necesarios de manera no interactiva, incluidas las siguientes líneas:
# RUN apt-get update actualiza la lista de los paquetes que esten disponibleas, ""&&"" nos ejecutara
# el siguiente comando siempre y cuando el anterior haya tenido éxito y "apt-get install -y \" instalará los 
# paquetes especificos para el contenedor
    RUN apt-get update && apt-get install -y \
    # esta parte es para el servidor apache
    apache2 \  
    php \
    #esta es para la parte que interactua con mysql y la de arriba es para la de php
    php-mysql \
    #Servidor de bases de datos MySQL.
    mysql-server \
    #Limpiará el caché para hacer menor el tamaño de la imagen
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


#podemos estar seguros de que se procesarán los archivos de php en el dockerfile, donde se usará la versión 7.4 de php, lo que nos da la posibilidad
#de configurar un servidor web con pho
RUN a2enmod php7.4

#Se marca la direccion con ceros para que nuestro sitio pueda recibir visitas por así decirlo desde cualquier direccion ip o cualquier contenedor
#no sirve en un entorno de desarrollo local para poder acceder desde caulquier dispositivo
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

#aseguramos que los archivos o directorios existan en nuestro contenedor y en caso de no existir procederá a crearlos, mismo directorio
#tendra los archivos donde se inicialice la bd
RUN mkdir -p /docker-entrypoint-initdb.d

# Esta linea va a copiar el archivo desde el directorio donde tenemos nuestro dockerfile de forma local y lo pegará dentro del contenedor.
COPY init-db.sh /docker-entrypoint-initdb.d/

# L de damos el poder de cambiar los permisos de nuestro archivo para que se vuelva ejecutable
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

#hace que se pueda ver o se copie todos los archivos que hayan en el directorio www, para que se pueda acceder desde el sitio web
COPY www/ /var/www/html/

#Se preparan los puertos 80 de apache y 3306 de mysql lo que nos facilita la comunicación para que puedan ser accesibles
EXPOSE 80 3306

# copy es la instrucción para copiar
COPY start-services.sh /usr/local/bin/

#el change mode nos sirve para cambiar los permisos del archivo .sh para que sea ejecutable cuando se llame
RUN chmod +x /usr/local/bin/start-services.sh

#Este comando se ejecuta cuando se encienda o inicie el contenedor, una vez que esté listo se ejecuta el archivo . sh
CMD ["/usr/local/bin/start-services.sh"]