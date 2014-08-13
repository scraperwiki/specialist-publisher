class ManualSectionPublishingAPIExporter

  def initialize(export_recipent, organisations_api, document_renderer, manual, document)
    @export_recipent = export_recipent
    @organisations_api = organisations_api
    @document_renderer = document_renderer
    @manual = manual
    @document = document
  end

  def call
    export_recipent.put_content_item(base_path, exportable_attributes)
  end

private

  attr_reader :export_recipent, :document_renderer, :organisations_api, :manual, :document

  def base_path
    "/#{rendered_document_attributes[:slug]}"
  end

  def exportable_attributes
    {
      base_path: base_path,
      format: "manual-section",
      title: rendered_document_attributes[:title],
      description: rendered_document_attributes[:summary],
      public_updated_at: rendered_document_attributes[:updated_at],
      update_type: update_type,
      publishing_app: "specialist-publisher",
      rendering_app: "manuals-frontend",
      routes: [
        {
          path: base_path,
          type: "exact",
        }
      ],
      details: {
        body: rendered_document_attributes[:body],
        breadcrumbs: [],
        child_section_groups: [],
        manual: {
          base_path: "/#{manual.attributes[:slug]}",
        },
        organisations: [
          organisation_info
        ],
      }
    }
  end

  def update_type
    document.minor_update? ? "minor" : "major"
  end

  def rendered_document_attributes
    @rendered_document_attributes ||= document_renderer.call(document).attributes
  end

  def organisation_info
    {
      title: organisation.title,
      abbreviation: organisation.details.abbreviation,
      web_url: organisation.web_url,
    }
  end

  def organisation
    @organisation ||= organisations_api.organisation(manual.organisation_slug)
  end
end
