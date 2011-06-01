
# ovveride Padrino error handling
# so we can generate a default error action
module Padrino
  class Application
    def self.default_errors!
    end
  end
end
