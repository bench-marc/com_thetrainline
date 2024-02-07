# frozen_string_literal: true

require_relative "com_thetrainline/version"

autoload :DateTime, "date"

module ComThetrainline
  class Error < StandardError; end

  def self.find(from, to, departure_at)
    Client.new(from, to, departure_at).call
  end
end
