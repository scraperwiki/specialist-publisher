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

`/etc/hosts` currently looks like

```
192.168.9.110   github.gds
10.1.1.254      specialist-publisher.dev.gov.uk
10.1.1.254      specialist-frontend.dev.gov.uk
10.1.1.254      static.dev.gov.uk
10.1.1.254      contentapi.dev.gov.uk
10.1.1.254      rummager.dev.gov.uk
10.1.1.254      panopticon.dev.gov.uk
10.1.1.254      www.dev.gov.uk
10.1.1.254      assets-origin.dev.gov.uk
10.1.1.254      dev.gov.uk
```

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

### Viewing documents in the VM

We also had to install a whole host of other repositories to get things
working for viewing and publishing documents:

* [`asset-manager`](https://github.com/alphagov/asset-manager)
* `development` (from GDS enterprise GitHub),
* [`fact-cave`](https://github.com/alphagov/fact-cave)
* [`finder-api`](https://github.com/alphagov/finder-api)
* [`govuk_content_api`](https://github.com/alphagov/govuk_content_api)
* [`imminence`](https://github.com/alphagov/imminence)
* [`specialist-frontend`](https://github.com/alphagov/specialist-frontend)
* [`static`](https://github.com/alphagov/static)

On installing them, you need to do `bundle install`.

You may also need to do `bundle exec rake db:migrate`

The `development` repository lets you do:

`bowl specialist-publisher specialist-frontend`

This starts all the dependencies: you don't need to run them
individually.

You can also run all the dependencies minus some e.g.

`bowl specialist-publisher --without-specialist-publisher` (not sure of
exact syntax of the `without`)

If you have started some of the dependencies manually, `bowl` may fail
due to them already running. The error code then terminates all the
processes that it has started. To fix, the quick, brutal way is `killall
-9 ruby`.

#### Updating local repos

`git fetch` and `git rebase` then do `bundle install` in case of new
dependencies. You may also need to do `bundle exec rake db:migrate` if
you see that there are changes in `db:migrate` (not entirely sure where
you see these mentions).

#### Running tests

`bundle exec ruby` (Where?)

`bundle exec cucumber --profile build` (Are the `cucumber` tests run as
part of the `bundle exec ruby` command?)

#### Incorrect attachment links

We had an issue where attachment links weren't generated correctly in
the published reports. They were just redirecting to the report page.

This was something to do with a missing bearer token or no gds-test
user perhaps?

Fixed by commenting out `before_filter :require_signin_permission!` in
`asset-manager`.

The link itself still won't work, but if it has a download icon by it,
then everything should be OK.

#### Bulk republishing documents

Run `specialist-publisher/lib/document_republisher.rb`.

Can specify the type of report to republish, e.g. CMA, AAIB.

e.g. `document_republisher.rb aaib_reports`

#### Bulk publishing documents

There's no script to do this automatically. GDS don't yet have a use
case for it (though they may in future). It *may* be possible to edit
`lib/document_republisher.rb` to remove the select statement from the
`repo.all.lazy.select(&:published?) line.

#### Clearing out documents

To get rid of documents, could do:
```
Artefact.all.map(&:destroy)
SpecialistDocumentEdition.all.map(&:destroy)
RenderedSpecialistDocument.all.map(&:destroy)
```

You can actually use `destroy_all` rather than do `map(&:destroy)`.

In the ScraperWiki `specialist_publisher` branch,
`add-clear-documents-rake-task` contains a script that allows you to
`bundle exec rake dev:clear_documents` is a script that does (I think):

```
Artefact.destroy_all
SpecialistDocumentEdition.destroy_all
RenderedSpecialistDocument.destroy_all`
```

(The script lives in `/lib/tasks/dev.rake`.)

#### Document types

* `Artefact` is an entity that belongs to `panopticon` (not sure
  exactly); 
* `RenderedSpecialistDocument` is a published document;
* `SpecialistDocumentEdition` is a little bit like a version of a
document, you can have different editions of the same document.

If you modify a draft, it modifies the current edition. If you modify a
published document, it creates a new edition.

#### Viewing documents

Once you've published a document, you get a link to it. However, in our
setup, it redirects to `www.dev.gov.uk` which is broken for reasons
unknown (not sure if specific to our VM). The actual domain is
`specialist-frontend.dev.gov.uk`.

#### Other useful things to know

* Run `bundle exec rake -T` to list all `rake` tasks.
* Can open a console in `specialist-publisher` directory; use `bundle exec
  rails console`.
* Debugging: add `require "binding.pry"; binding.pry` where you want the
  code to stop. It sets a breakpoint where you can inspect the code
  state.
