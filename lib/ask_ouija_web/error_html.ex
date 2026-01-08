defmodule AskOuijaWeb.ErrorHTML do
  use AskOuijaWeb, :component

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
