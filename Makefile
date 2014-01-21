# Note that the prefix affects the init scripts as well.
prefix := usr/local

clean:
	rm *.jar -f
	rm *.rpm -f
	rm *.deb -f
	rm *.jar -f
	git submodule init
	git submodule update
	rm -rf marathon/target

.PHONY: deb
deb: version with-upstart
	cd toor && \
	fpm -t deb -s dir \
	    -n marathon -v `cat ../version` -p ../marathon-`cat ../version`_amd64.deb .

.PHONY: rpm
rpm: version with-upstart
	cd toor && \
	fpm -t rpm -s dir \
	    -n marathon -v `cat ../version` -p ../marathon.rpm .

.PHONY: deb
deb: version with-upstart
	cd toor && \
	fpm -t deb -s dir \
	    -n marathon -v `cat ../version` -p ../marathon.deb .

.PHONY: osx
osx: version just-jar
	cd toor && \
	fpm -t osxpkg --osxpkg-identifier-prefix io.mesosphere -s dir \
	    -n marathon -v `cat ../version` -p ../marathon.pkg .

.PHONY: with-upstart
with-upstart: just-jar marathon.conf
	cp marathon.conf toor/etc/init/

.PHONY: just-jar
just-jar: marathon-runnable.jar
	mkdir -p toor/$(prefix)/bin toor/etc/init
	cp marathon-runnable.jar toor/$(prefix)/bin/marathon
	chmod 755 toor/$(prefix)/bin/marathon

version: plugin := org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate
version: marathon-runnable.jar
	( cd marathon && \
	  mvn $(plugin) -Dexpression=project.version | sed '/^\[/d' ) | \
	  tail -n1 > version

marathon-runnable.jar: clean
	cd marathon && mvn package && bin/build-distribution
	cp marathon/target/$@ $@

