class ViewAdapterRegistry
  def for_document(document)
    get(document.document_type).new(document)
  end

  private

  def get(type)
    {
      "aaib_report" => AaibReportViewAdapter,
      "cma_case" => CmaCaseViewAdapter,
      "drug_safety_update" => DrugSafetyUpdateViewAdapter,
      "international_development_fund" => InternationalDevelopmentFundViewAdapter,
      "medical_safety_alert" => MedicalSafetyAlertViewAdapter,
    }.fetch(type)
  end
end