defmodule Phx177Web.ErrorJSONTest do
  use Phx177Web.ConnCase, async: true

  test "renders 404" do
    assert Phx177Web.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Phx177Web.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
