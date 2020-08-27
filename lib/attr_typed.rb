# frozen_string_literal: true

require "monetize"
require "money"
require "bigdecimal"
require "date"

# Ability to mix in some strong typing support for attributes
#
# Usage:
#   attr_typed my_field: money,
#              another_field: time
#
# Then on assigning my_field = "1.23", my_field will be co-erced to Money.new(123) ($1.23)
#
# Gotchas:
#   - Don't use instance variable assignment (Use self.my_field= as opposed to @my_field=)
#   - Due to the way string.to_f works in ruby, self.my_field = "cats" will equal $0.00
#
module AttrTyped
  ALLOWED_TYPES ||= %i[
    string money time big_decimal date integer strict_integer boolean date_time
  ].freeze

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  class << self
    attr_accessor :logger
  end

  def parse_typed_value(value, type)
    public_send("parse_#{type}", value) unless value.nil?
  rescue ArgumentError => e
    AttrTyped&.logger&.error("Error parsing '#{value}' into a #{type}")
    raise e
  end

  def parse_string(value)
    return value if value.is_a?(String)

    value.to_s
  end

  def parse_integer(value)
    value.to_i
  end

  def parse_strict_integer(value)
    return value if value.nil? || value.is_a?(Integer)
    return value.to_i if value.is_a?(Float) || value.is_a?(BigDecimal)

    Integer(value, 10)
  rescue ArgumentError
    nil
  end

  def parse_date(value)
    return value if value.is_a?(Date)

    if Time.respond_to?(:zone)
      Time.zone.parse(value).to_date
    else
      Date.parse(value)
    end
  end

  def parse_date_time(value)
    return value if value.is_a?(DateTime)

    DateTime.parse(value)
  end

  def parse_big_decimal(value)
    return value if value.is_a?(BigDecimal)
    return value.to_d if value.is_a?(Float)

    BigDecimal(value)
  rescue ArgumentError
    BigDecimal(0)
  end

  def parse_money(value)
    return value if value.is_a?(Money)

    Monetize.from_bigdecimal(BigDecimal(value.to_s))
  rescue ArgumentError
    Money.new(0)
  end

  def parse_time(value)
    return value if value.is_a?(Time)

    raise "ActiveSupport with a time zone set is required" unless Time.respond_to?(:zone)

    Time.zone.parse(value)
  end

  def parse_boolean(value)
    return if value.nil? && !value.is_a?(FalseClass)
    return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)

    %w[true y].include?(value.to_s.downcase)
  end

  # Class method attr_typed
  module ClassMethods
    def attr_typed(attrs)
      attrs.each do |(attribute, type)|
        raise ArgumentError, "Unsupported type #{type}" unless ALLOWED_TYPES.include?(type)

        define_method("#{attribute}_with_typing=") do |value|
          instance_variable_set("@#{attribute}", public_send("parse_typed_value", value, type))
        end

        class_eval do
          attr_accessor attribute

          alias_method "#{attribute}_without_typing=", "#{attribute}="
          alias_method "#{attribute}=", "#{attribute}_with_typing="
        end
      end
    end
  end
end
