class AaibReportsController < ApplicationController

  before_filter :authorize_user

  rescue_from("SpecialistDocumentRepository::NotFoundError") do
    # TODO: Remove use of exceptions for flow control.
    redirect_to(manuals_path, flash: { error: "Document not found" })
  end

  def index
    documents = services.list_aaib_reports.call

    render(:index, locals: { documents: documents })
  end

  def show
    document = services.show_aaib_report(document_id).call

    render(:show, locals: { document: document })
  end

  def new
    document = services.new_aaib_report.call

    render(:new, locals: { document: form_object_for(document) })
  end

  def edit
    document = services.show_aaib_report(document_id).call

    render(:edit, locals: { document: form_object_for(document) })
  end

  def create
    document = services.create_aaib_report(document_params).call

    if document.valid?
      redirect_to(aaib_report_path(document))
    else
      render(:new, locals: { document: document })
    end
  end

  def update
    document = services.update_aaib_report(document_id, document_params).call

    if document.valid?
      redirect_to(aaib_report_path(document))
    else
      render(:edit, locals: { document: document })
    end
  end

  def publish
    document = services.publish_aaib_report(document_id).call

    redirect_to(aaib_report_path(document), flash: { notice: "Published #{document.title}" })
  end

  def withdraw
    document = services.withdraw_aaib_report(document_id).call

    redirect_to(aaib_reports_path, flash: { notice: "Withdrawn #{document.title}" })
  end

  def preview
    preview_html = services.preview_aaib_report(params.fetch("id", nil), document_params).call

    render json: { preview_html: preview_html }
  end

protected

  def form_object_for(document)
    AaibReportForm.new(document, finder_schema)
  end

  def authorize_user
    unless user_can_edit_aaib_reports?
      redirect_to manuals_path, flash: { error: "You don't have permission to do that." }
    end
  end

  def document_id
    params.fetch("id")
  end

  def document_params
    report_params = params.fetch("aaib_report", {})
    report_params["aircraft_category"] = filter_blank_multi_select(report_params["aircraft_category"])
    report_params
    # This is bad! Rewrite it!
  end

  # See http://stackoverflow.com/questions/8929230/why-is-the-first-element-always-blank-in-my-rails-multi-select
  def filter_blank_multi_select(values)
    values.is_a?(Array) ? values.reject(&:blank?) : values
  end

  def finder_schema
    SpecialistPublisherWiring.get(:aaib_report_finder_schema)
  end
  helper_method :finder_schema
end
