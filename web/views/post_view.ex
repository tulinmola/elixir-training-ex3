defmodule Blog.PostView do
  use Blog.Web, :view

  @month_names ~w(Jan Feb Mar Apr May June July Aug Sept Oct Nov Dec)

  def calendar(date) do
    day_tag = content_tag :span, date.day, class: "calendar-day"
    month = Enum.at(@month_names, date.month - 1)
    month_tag = content_tag :span, month, class: "calendar-month"
    content_tag :div, [month_tag, day_tag], class: "calendar"
  end
end
