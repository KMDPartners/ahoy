require_relative "../test_helper"

class PostgresqlJsonbEvent < PostgresqlBase
end

class PostgresqlJsonbTest < Minitest::Test
  include QueryMethodsTest

  def model
    PostgresqlJsonbEvent
  end
end
