defmodule Blog.PostControllerTest do
  use Blog.ConnCase

  alias Blog.{Post, Repo}
  @valid_attrs %{author: "John Doe", content: "Lorem", title: "Ipsum"}
  @invalid_attrs %{}

  def create_post do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    Repo.insert!(changeset)
  end

  test "lists all entries on index", %{conn: conn} do
    post = create_post
    conn = get conn, post_path(conn, :index)
    html = html_response(conn, 200)

    list = Floki.find(html, "ul.posts")
    assert list |> Enum.count == 1

    items = Floki.find(html, "ul.posts > li")
    assert items |> Enum.count == 1

    [item] = items
    assert item |> Floki.find(".calendar") |> Enum.count == 1
    assert item |> Floki.find("h3") |> Floki.text =~ post.title
    assert item |> Floki.find(".post-author") |> Floki.text =~ post.author
    assert item |> Floki.find(".post-content.line-clamp") |> Floki.text =~ post.content

    buttons = Floki.find(html, "ul.buttons")
    assert buttons |> Enum.count == 1

    new_post = Floki.find(buttons, "a[href=\"#{post_path(conn, :new)}\"]")
    assert new_post |> Enum.count == 1
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, post_path(conn, :new)
    html = html_response(conn, 200)

    form = Floki.find(html, "form")
    fields = Floki.find(form, ".field")
    assert fields |> Enum.count == 3

    [author_field, title_field, content_field] = fields
    assert Floki.find(author_field, "input[name=\"post[author]\"]") |> Enum.count == 1
    assert Floki.find(title_field, "input[name=\"post[title]\"]") |> Enum.count == 1
    assert Floki.find(content_field, "textarea[name=\"post[content]\"]") |> Enum.count == 1

    submit = Floki.find(form, "[type=\"submit\"]")
    assert submit |> Enum.count == 1

    buttons = Floki.find(html, "ul.buttons")
    assert buttons |> Enum.count == 1

    back = Floki.find(buttons, "a[href=\"#{post_path(conn, :index)}\"]")
    assert back |> Enum.count == 1
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :index)
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    html = html_response(conn, 200)

    form = Floki.find(html, "form")
    fields = Floki.find(form, ".field")
    assert fields |> Enum.count == 3

    [author_field, title_field, content_field] = fields
    assert Floki.find(author_field, "span.help-block") |> Enum.count == 1
    assert Floki.find(title_field, "span.help-block") |> Enum.count == 1
    assert Floki.find(content_field, "span.help-block") |> Enum.count == 1
  end

  test "shows chosen resource", %{conn: conn} do
    post = create_post
    conn = get conn, post_path(conn, :show, post)
    html = html_response(conn, 200)

    assert html |> Floki.find(".calendar") |> Enum.count == 1
    assert html |> Floki.find("h3") |> Floki.text =~ post.title
    assert html |> Floki.find(".post-author") |> Floki.text =~ post.author
    assert html |> Floki.find(".post-content") |> Floki.text =~ post.content

    buttons = Floki.find(html, "ul.buttons")
    assert buttons |> Enum.count == 1

    edit = Floki.find(buttons, "a[href=\"#{post_path(conn, :edit, post)}\"]")
    assert edit |> Enum.count == 1

    back = Floki.find(buttons, "a[href=\"#{post_path(conn, :index)}\"]")
    assert back |> Enum.count == 1
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    post = create_post
    conn = get conn, post_path(conn, :edit, post)
    html = html_response(conn, 200)

    form = Floki.find(html, "form")
    assert form |> Enum.count == 1

    buttons = Floki.find(html, "ul.buttons")
    assert buttons |> Enum.count == 1

    back = Floki.find(buttons, "a[href=\"#{post_path(conn, :index)}\"]")
    assert back |> Enum.count == 1
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    post = create_post
    conn = put conn, post_path(conn, :update, post), post: %{title: "updated"}
    assert redirected_to(conn) == post_path(conn, :show, post)
    assert Repo.get_by(Post, %{title: "updated"})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    post = create_post
    conn = put conn, post_path(conn, :update, post), post: %{title: ""}
    html = html_response(conn, 200)

    form = Floki.find(html, "form")
    assert form |> Enum.count == 1
  end

  test "deletes chosen resource", %{conn: conn} do
    post = create_post
    conn = delete conn, post_path(conn, :delete, post)
    assert redirected_to(conn) == post_path(conn, :index)
    refute Repo.get(Post, post.id)
  end
end
