## Spokehaus.ca

Get the sources
```sh
$ git clone git@github.com:unspace/spokehaus.ca.git
```

Provision Vagrant
```sh
$ script/provision_vagrant
```

Configuration:
```sh
$ cp config/secrets.yml.example config/secrets.yml
```

Start vagrant:
```sh
$ vagrant ssh
$ cd /vagrant
```

Bootstrap: (bundle, migrate, etc)
```sh
$ script/bootstrap
```

Start the server:
```sh
$ script/server
```
