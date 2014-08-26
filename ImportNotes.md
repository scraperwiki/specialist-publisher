# Import Notes

## Project Structure

* app/models contains objects that represent "things"
* app/services contains command objects that perform actions eg "CreateDocument"
* app/importers Import related code lives here.

DocumentImport contains generic code for running an import. Format
specific code will live in a namespace under app/importers/aaib_reports for example.

## Entry point

There is an executable Ruby script in the bin directory for each format specific
import.

### AAIB Import code

#### DependencyContainer

Instantiates all the concrete objects and introduces objects to their
dependencies.

`#get_instance` provides a configured instance of BulkImporter which iterates
through the import data and executes individual import tasks.

Provides the file reader / parser function which it maps a file path glob over.

#### Mappers

There are two mappers for converting data between the arbitrary imported data
and the data format we expect. This is the place to map categories or wrangle
text.

Body text must conform to the GOVUK [Styleguide](https://www.gov.uk/design-principles/style-guide)

Mappers are stacked one on top of another to provide a chain of single-responsibility
objects which perform their task on the data and call down the stack.

At the bottom of the stack will be a "service object" which actually creates a
document.

## Installation

### Dependencies

* GDS' puppet repo
* [Panopticon](https://github.com/alphagov/panopticon)
* [Rummager](https://github.com/alphagov/rummager)

Start the VM with `vagrant up` and SSH in with `vagrant SSH`.

### Hosts

Modify `/etc/hosts` with:

```
10.1.1.254 specialist-publisher.dev.gov.uk
```

### Starting specialist-publisher and dependencies

Run `startup.sh` in each folder in /var/govuk

### Importing documents

Example: import AAIB reports.

Place the reports to some convenient location, e.g.:

```
~/aaib_content/metadata
~/aaib_content/downloads
```

Then,

`./import_aaib_reports ~/aaib_content/metadata/ ~/aaib_content/` should
start importing the reports as draft.

### Publishing documents

Visit `specialist-publisher.dev.gov.uk`. Click on a draft publication
and click "Publish".

You need to be running Panopticon to work without error.

Note that this command:

`PLEK_SERVICE_WHITEHALL_ADMIN_URI=https://www.gov.uk/ bundle exec rake
organisations:import`

must be run before trying this, else you get an error of:

`Tag::MissingTags in ArtefactsController#update`

If you've done that and are **not** running Rummager, you'll get a 502
Bad Gateway with url: `http://search.dev.gov.uk/documents`

### Viewing documents

**TODO: update**
