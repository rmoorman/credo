defmodule Credo.Check.Readability.SpaceAfterCommasTest do
  use Credo.TestHelper

  @described_check Credo.Check.Readability.SpaceAfterCommas

  #
  # cases NOT raising issues
  #

  test "it should NOT report when commas have spaces" do
"""
defmodule CredoSampleModule do
    @attribute {:foo, :bar}
end
""" |> to_source_file
    |> refute_issues(@described_check)
  end

  test "it should NOT report when commas have newlines" do
"""
defmodule CredoSampleModule do
    defstruct foo: nil,
              bar: nil
end
""" |> to_source_file
    |> refute_issues(@described_check)
  end

  test "it should NOT require spaces after commas preceded by the `?` operator" do
"""
defmodule CredoSampleModule do
    @some_char_codes [?,, ?;]
end
""" |> to_source_file
    |> refute_issues(@described_check)
  end

  #
  # cases raising issues
  #

  test "it should report when commas are not followed by spaces" do
"""
defmodule CredoSampleModule do
    @attribute {:foo,:bar}
end
""" |> to_source_file
    |> assert_issue(@described_check, fn(issue) ->
        assert 21 == issue.column
        assert ",:" ==  issue.trigger
      end)
  end

  test "it should report when there are many commas not followed by spaces" do
"""
defmodule CredoSampleModule do
  @attribute [1,2,3,4,5]
end
""" |> to_source_file
    |> assert_issues(@described_check, fn(issues) ->
        assert 4 == Enum.count(issues)
        assert [16, 18, 20, 22] == Enum.map(issues, &(&1.column))
        assert [",2", ",3", ",4", ",5"] == Enum.map(issues, &(&1.trigger))
    end)
  end

  test "it requires spaces after commas preceded by the `?,`" do
"""
defmodule CredoSampleModule do
    @some_char_codes [?,,?;]
end
""" |> to_source_file
    |> assert_issue(@described_check)
  end

  test "it requires spaces after commas preceded by variables ending with a ?" do
"""
defmodule CredoSampleModule do
    @attribute [question?,answer]
end
""" |> to_source_file
    |> assert_issue(@described_check)
  end
end
