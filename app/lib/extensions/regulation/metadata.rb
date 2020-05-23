# frozen_string_literal: true

module Extensions
  module Regulation
    class Metadata
      include Comparable

      def <=>(other)
        number <=> other.number
      end

      ATTRIBUTES = {
        identifier:   { required: true, types: [Symbol] },
        klass:        { required: true, types: [Regulation::Article] },
        version:      { required: true, types: [String, Integer] },
        number:       { required: true, types: [String, Integer] },
        sub_articles: { required: false, types: [Array] },
        store:        { required: true, types: [Symbol] }
      }.freeze

      ATTRIBUTES.each_key do |attr|
        attr_reader attr
      end

      def initialize(attributes = {})
        ATTRIBUTES.each_key { |attr| instance_variable_set("@#{attr}", attributes[attr] || nil) }

        valid!
      end

      def sub_articles
        [*@sub_articles]
      end

      private

      def valid!
        ATTRIBUTES.each do |attr, options|
          required, types = options.values_at(:required, :types)
          data            = public_send(attr)

          next unless required

          raise ArgumentError, "#{attr} property should not be empty" if required && data.blank?

          next if types.any? { |type| check_type(data, type) }

          raise ArgumentError, "#{attr} type must be #{'any of ' if types.count > 1}#{types.to_sentence}"
        end
      end

      def check_type(data, type)
        data.is_a?(Class) ? data.superclass == type : data.is_a?(type)
      end
    end
  end
end
