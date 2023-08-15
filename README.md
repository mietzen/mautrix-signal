# [`mautrix/signal`](https://mau.dev/mautrix/signal/) with integrated [`signald`](https://gitlab.com/signald/signald)

`signald` is build from source because we need a `musl` version for alpine linux.
The generated `config.yaml` points to the new internal `signald` socket at: `/var/run/signald/signald.sock`

`docker compose` example:

```yaml
version: '3.8'

services:
  synapse:
    image: matrixdotorg/synapse:latest
    container_name: synapse
    environment:
      - UID=1000
      - GID=1000
    volumes:
      - ./synapse:/data
    networks:
      - matrix
  mautrix-signal:
    image: "mietzen/mautrix-signal:latest"
    container_name: mautrix-signal
    volumes:
      - ./mautrix-signal:/data
    networks:
      - matrix
    depends_on: 
      - synapse

networks:
  matrix:
```
For configuration see: [Mautrix-Docs](https://docs.mau.fi/bridges/python/signal/docker-setup.html)

### License:
[AGPL-3.0](LICENSE)

### Dependencies:
- [mautrix/signal](https://mau.dev/mautrix/signal/): [AGPL-3.0](https://mau.dev/mautrix/signal/-/blob/master/LICENSE)
- [signald](https://gitlab.com/signald/signald): [GPL-3.0](https://gitlab.com/signald/signald/-/blob/main/LICENSE?ref_type=heads)
