grondview
=========

assumes a `vagrant up` precise64.box environment. Packages from apt+pypi

proper postgresql account is set up with the puppet postgresql module.

run `python manage.py syncdb` to create a user account for the site.

run `./runserver.sh` to start the development server

connect to http://localhost:8000 on host machine.
