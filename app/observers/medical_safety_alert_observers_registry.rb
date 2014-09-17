class MedicalSafetyAlertObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:medical_safety_alert_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:medical_safety_alert_content_api_exporter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:medical_safety_alert_rummager_indexer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:medical_safety_alert_rummager_deleter)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end
end
