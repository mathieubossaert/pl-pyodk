# PostGIS docker image to try pyODK in pl/python function

```sh
sudo docker build -t postgis:test_pyodk .
sudo docker run --restart="always" --name postgis_v15_3 -e POSTGRES_PASSWORD=dbroot -d -p 5555:5432 postgis:test_pyodk
```