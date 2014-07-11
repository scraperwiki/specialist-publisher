require "forwardable"

class DocumentForm < SimpleDelegator

  extend Forwardable
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "SpecialistDocument")
  end

  def initialize(document, finder_schema)
    @document = document
    @finder_schema = finder_schema
    super(document)
  end

  def attachments
    document && document.attachments || []
  end

  def persisted?
    document && document.updated_at
  end

  def to_param
    document.id
  end

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

private

  attr_reader :document, :finder_schema

  def delegate_if_document_exists(attribute_name)
    document && document.public_send(attribute_name)
  end
end
