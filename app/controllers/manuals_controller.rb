class ManualsController < ApplicationController
  def index
    all_manuals = services.list(self).call

    render(:index, locals: { manuals: all_manuals })
  end

  def show
    manual, metadata = services.show(manual_id).call
    slug_unique = metadata.fetch(:slug_unique)
    clashing_sections = metadata.fetch(:clashing_sections)

    render(:show, locals: {
      manual: manual,
      slug_unique: slug_unique,
      clashing_sections: clashing_sections,
    })
  end

  def new
    manual = services.new(self).call

    render(:new, locals: { manual: manual_form(manual) })
  end

  def create
    manual = services.create(manual_params).call
    manual = manual_form(manual)

    if manual.valid?
      redirect_to(manual_path(manual))
    else
      render(:new, locals: {
        manual: manual,
      })
    end
  end

  def edit
    manual, _metadata = services.show(manual_id).call

    render(:edit, locals: { manual: manual_form(manual) })
  end

  def update
    manual = services.update(manual_id, manual_params).call
    manual = manual_form(manual)

    if manual.valid?
      redirect_to(manual_path(manual))
    else
      render(:edit, locals: {
        manual: manual,
      })
    end
  end

  def publish
    manual = services.queue_publish(manual_id).call

    redirect_to(
      manual_path(manual),
      flash: { notice: "Published #{manual.title}" },
    )
  end

  def preview
    manual = services.preview(params["id"], manual_params).call

    manual.valid? # Force validation check or errors will be empty

    if manual.errors[:body].blank?
      render json: { preview_html: manual.body }
    else
      render json: {
        preview_html: render_to_string(
          "shared/_preview_errors",
          layout: false,
          locals: {
            errors: manual.errors[:body]
          }
        )
      }
    end
  end

private
  def manual_id
    params.fetch("id")
  end

  def manual_params
    params
      .fetch("manual", {})
      .slice(*valid_params)
      .merge(
        organisation_slug: current_organisation_slug,
      )
      .symbolize_keys
  end

  def valid_params
    %i(
      title
      summary
      body
    )
  end

  def manual_form(manual)
    ManualViewAdapter.new(manual)
  end

  def services
    @services ||= OrganisationalManualServiceRegistry.new(
      organisation_slug: current_organisation_slug,
    )
  end
end
