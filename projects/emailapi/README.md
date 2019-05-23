# Setup

* Install Vagrant(2.2.4), and virtual box (5.2.26 r128414).
* Clone this repo.
* From the command line run: `vagrant up` from the root of the repo clone.  This will take a minute.
* SSH onto the vagrant box: `vagrant ssh`
* Go to project directly `cd /projets/emailapi/`
* Install requirements.  `pip3 install -r requirements.txt`
* Run Tests (`projects/emailapi/api/tests/test_views.py`) : `MAILGUN_API_TOKEN=<your-token> python3 ./manage.py test`
* Test through the API:
  * Run webserver `MAILGUN_API_TOKEN=<your-token> python3 ./manage.py runserver 0.0.0.0:8080&`
  * Wait a second for the webserver to start
  * Try a curl:
```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"to": "ben@perfectresolution.com","to_name": "Mr. Fake","from": "noreply@mybrightwheel.com","from_name": "Brightwheel","subject": "A Message from Brightwheel","body": "<h1>Your Bill</h1><p>$10</p>"}' \
  http://localhost:8080/api/email
```
* `vagrant destroy` from your host to destroy the VM.

# Technical Choices

This application uses the following technologies:

* Python3.  This is my perfered programming language for working with data.  It's fine for web too.
* Django.  Overkill for this task, however I am familiar with it so it was quick to use.  In general I like django
  since it comes with a test harness, and web utilities like `strip_tags`.
* Requests.  Simplest package for making web requests.
* Vagrant/Virtual Box. I'm using vagrant/virtual box because docker does not run on Windows Home edition.  In general
  virtualization eases deployment via making a consistent server-like environment to run application.
* Mailgun.  We used mailgun at a previous company, even though I never messed with the code.  I did add auditing around
  its use however.