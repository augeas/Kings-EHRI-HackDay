# Kings-EHRI-HackDay

Build the Docker container:
sudo docker build -t ehack Kings-EHRI-HackDay/

Run the Docker container:
docker run --name hackday -v /path/to/data:/home/ehri -p 80:80 -p 8888:8888 -p 8022:22 -t -i ehack 

