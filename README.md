# email2pdf

email2pdf is a Python script to convert emails to PDF from the command-line.
email2pdf acts in place of a [mail delivery
agent](http://en.wikipedia.org/wiki/Mail_delivery_agent) - it won't retrieve
emails for you, but it will take them from standard input as an MDA will and
'deliver' them to PDF files. It is well-placed to use together with
[getmail](http://pyropus.ca/software/getmail/). You can also just use it as a
standalone utility to convert a raw email (normally an
[.eml](https://en.wikipedia.org/wiki/Email#Filename_extensions) file) to a
PDF. Type `email2pdf --help` for more information on usage and options
available.

For more information on hacking/developing email2pdf, please see
[HACKING.md](https://github.com/andrewferrier/email2pdf/blob/master/HACKING.md).
Note that use is subject to the [license
conditions](https://github.com/andrewferrier/email2pdf/blob/master/LICENSE.txt).

## Installing Dependencies

Before you can use email2pdf, you need to install some dependencies. The
instructions here are split out by platform:

### Debian/Ubuntu

* [wkhtmltopdf](http://wkhtmltopdf.org/) - Install the `.deb` from
  http://wkhtmltopdf.org/ rather than using apt-get to minimise the
  dependencies you need to install (in particular, to avoid needing a package
  manager).

* [getmail](http://pyropus.ca/software/getmail/) - getmail is optional, but it
  works well as a companion to email2pdf. Install using `apt-get install
  getmail`.

* Others - there are some other Python library dependencies. Run `make
  builddeb` to create a `.deb` package, then install it with `dpkg -i
  mydeb.deb`. This will prompt you regarding any missing dependencies.

### OS X

* [wkhtmltopdf](http://wkhtmltopdf.org/) - Install the package from
  http://wkhtmltopdf.org/downloads.html.

* [getmail](http://pyropus.ca/software/getmail/) - TODO: This hasn't been
  tested, so there are no instructions here yet! Note that getmail is
  optional.

* Install [Homebrew](http://brew.sh/)

* `xcode-select --install` (for lxml, because of
  [this](http://stackoverflow.com/questions/19548011/cannot-install-lxml-on-mac-os-x-10-9))

* `brew install python3` (or otherwise make sure you have Python 3 and `pip3`
  available).

* `brew install libmagic`

* `pip3 install beautifulsoup4 lxml pypdf2 python-magic requests`

## Configuring getmail

getmail is not strictly a dependency, but when it is combined with email2pdf,
it can be used to retrieve new emails from a remote IMAP server and
automatically convert them to PDFs locally. The
[`getmailrc.sample`](https://github.com/andrewferrier/email2pdf/blob/master/getmailrc.sample)
file in the repository can be used as a starting point for your own getmailrc
to do this. Note that the sample will need editing, of course - see the
getmail documentation for more information on that. Also, it is configured by
default to *delete* remote emails from the server once they are converted - be
careful with that. You might want to consider setting up your crontab
something like this:

```
  @hourly getmail --verbose | logger
```

This will ensure that getmail is invoked hourly to fetch email, and log its
output to syslog.
