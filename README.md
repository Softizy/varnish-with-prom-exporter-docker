# [varnish-with-prom-exporter-docker](https://github.com/Softizy/varnish-with-prom-exporter-docker)

Varnish docker container with prometheus_varnish_exporter baked in

## Usage

```shell
docker pull ghcr.io/softizy/varnish-with-prom-exporter-docker:latest
docker run -p 8080:8080 -p 8443:8443 -p 9131:9131 -v /path/to/your.vcl:/etc/varnish/default.vcl ghcr.io/softizy/varnish-with-prom-exporter-docker:latest
```

Tag template : `{varnish-version}-{varnish-exporter-version}`

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
