TEMPDIR := $(shell mktemp -t tmp.XXXXXX -d)
FLAKE8 := $(shell which flake8)
DOCKERTAG = andrewferrier/email2pdf

determineversion:
	$(eval GITDESCRIBE := $(shell git describe --dirty))
	sed 's/Version: .*/Version: $(GITDESCRIBE)/' debian/DEBIAN/control_template > debian/DEBIAN/control

builddeb: determineversion builddeb_real

builddeb_real:
	sudo apt-get install build-essential
	cp -R debian/DEBIAN/ $(TEMPDIR)
	mkdir -p $(TEMPDIR)/usr/bin
	mkdir -p $(TEMPDIR)/usr/share/doc/email2pdf
	cp email2pdf $(TEMPDIR)/usr/bin
	cp README* $(TEMPDIR)/usr/share/doc/email2pdf
	cp LICENSE* $(TEMPDIR)/usr/share/doc/email2pdf
	cp getmailrc.sample $(TEMPDIR)/usr/share/doc/email2pdf
	fakeroot chmod -R u=rwX,go=rX $(TEMPDIR)
	fakeroot chmod -R u+x $(TEMPDIR)/usr/bin
	fakeroot dpkg-deb --build $(TEMPDIR) .

builddocker: determineversion
	docker build -t $(DOCKERTAG) .
	docker tag $(DOCKERTAG):latest $(DOCKERTAG):$(GITDESCRIBE)

builddocker_nocache: determineversion
	docker build --no-cache -t $(DOCKERTAG) .
	docker tag $(DOCKERTAG):latest $(DOCKERTAG):$(GITDESCRIBE)

rundocker_interactive: builddocker
	docker run -i -t $(DOCKERTAG) /sbin/my_init -- bash -l

rundocker_testing: builddocker
	docker run -t $(DOCKERTAG) /sbin/my_init -- bash -c 'cd /tmp/email2pdf && make unittest && make stylecheck'

rundocker_getdebs: builddocker
	docker run -v ${PWD}:/debs $(DOCKERTAG) sh -c 'cp /tmp/*.deb /debs'

unittest:
	python3 -m unittest discover

unittest_verbose:
	python3 -m unittest discover -f -v

analysis:
	# Debian version is badly packaged, make sure we are using Python 3.
	/usr/bin/env python3 $(FLAKE8) --max-line-length=132 email2pdf .
	pylint --report=n --disable=line-too-long --disable=missing-docstring --disable=locally-disabled email2pdf

coverage:
	rm -rf cover/
	nosetests tests/Direct/*.py --with-coverage --cover-package=email2pdf,tests --cover-erase --cover-html --cover-branches
	open cover/index.html

alltests: unittest analysis coverage
