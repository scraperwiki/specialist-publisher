require "builders/specialist_document_builder"

class DrugSafetyUpdateReportBuilder < SpecialistDocumentBuilder

  def call(attrs)
    super(
      attrs.merge(document_type: "drug_safety_update")
    )
  end

end
