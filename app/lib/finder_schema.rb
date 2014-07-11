require "multi_json"

class FinderSchema
  def initialize(schema_path)
    @schema_path = schema_path
  end

  def facets
    schema.fetch("facets", []).map do |facet|
      facet.fetch("key").to_sym
    end
  end

  def options_for(facet_name)
    allowed_values_as_option_tuples(allowed_values_for(facet_name))
  end

  def label_for_facet_value(facet, values)
    Array(values).map do |value|
      if allowed_values_for(facet).any?
        allowed_values_for(facet).select { |option| option['value'] == value}.first.fetch("label")
      end
    end
  end

private
  def schema
    @schema ||= MultiJson.load(File.read(@schema_path))
  end

  def facet_data_for(facet_name)
    schema.fetch("facets", []).find do |facet_record|
      facet_record.fetch("key") == facet_name.to_s
    end || {}
  end

  def allowed_values_for(facet_name)
    facet_data_for(facet_name).fetch("allowed_values", [])
  end

  def allowed_values_as_option_tuples(allowed_values)
    allowed_values.map do |value|
      [
        value.fetch("label", ""),
        value.fetch("value", "")
      ]
    end
  end
end
