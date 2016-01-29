# Rumbl

Example app from Programming Phoenix.


To replicate the build error.

```
mix deps.get
mix test
```

All tests should pass.

Modify `mix.lock` for `phoenix_html` to `2.5.0`

```
mix deps.get
mix test
```

The exception should occur.

```
  1) test does not create video and renders errors when invalid (Rumbl.VideoControllerTest)
     test/controllers/video_controller_test.exs:47
     ** (FunctionClauseError) no function clause matching in Phoenix.HTML.Form.normalize_form/1
     stacktrace:
       (phoenix_html) lib/phoenix_html/form.ex:239: Phoenix.HTML.Form.normalize_form(%{__struct__: Phoenix.HTML.Form, errors: [url: "can't be blank", description: "can't be blank"], hidden: [], id: "video", impl: Phoenix.HTML.FormData.Ecto.Changeset, index: nil, model: %Rumbl.Video{__meta__: #Ecto.Schema.Metadata<:built>, annotations: #Ecto.Association.NotLoaded<association :annotations is not loaded>, category: #Ecto.Association.NotLoaded<association :category is not loaded>, category_id: nil, description: nil, id: nil, inserted_at: nil, slug: nil, title: nil, updated_at: nil, url: nil, user: #Ecto.Association.NotLoaded<association :user is not loaded>, user_id: 900}, name: "video", options: [method: "post"], params: %{"title" => "invalid"}, source: %Ecto.Changeset{action: :insert, changes: %{slug: "invalid", title: "invalid"}, constraints: [%{constraint: "videos_category_id_fkey", field: :category_id, message: "does not exist", type: :foreign_key}], errors: [url: "can't be blank", description: "can't be blank"], filters: %{}, model: %Rumbl.Video{__meta__: #Ecto.Schema.Metadata<:built>, annotations: #Ecto.Association.NotLoaded<association :annotations is not loaded>, category: #Ecto.Association.NotLoaded<association :category is not loaded>, category_id: nil, description: nil, id: nil, inserted_at: nil, slug: nil, title: nil, updated_at: nil, url: nil, user: #Ecto.Association.NotLoaded<association :user is not loaded>, user_id: 900}, optional: [:category_id], opts: [], params: %{"title" => "invalid"}, prepare: [], repo: Rumbl.Repo, required: [:url, :title, :description], types: %{annotations: {:assoc, %Ecto.Association.Has{cardinality: :many, defaults: [], field: :annotations, on_cast: :changeset, on_delete: :nothing, on_replace: :raise, owner: Rumbl.Video, owner_key: :id, queryable: Rumbl.Annotation, related: Rumbl.Annotation, related_key: :video_id}}, category_id: :id, description: :string, id: Rumbl.Permalink, inserted_at: Ecto.DateTime, slug: :string, title: :string, updated_at: Ecto.DateTime, url: :string, user_id: :id}, valid?: false, validations: []}})
       (phoenix_html) lib/phoenix_html/form.ex:234: Phoenix.HTML.Form.form_for/4
       (rumbl) web/templates/video/form.html.eex:1: Rumbl.VideoView."form.html"/1
       (rumbl) web/templates/video/new.html.eex:3: Rumbl.VideoView."new.html"/1
       (rumbl) web/templates/layout/app.html.eex:33: Rumbl.LayoutView."app.html"/1
       (phoenix) lib/phoenix/view.ex:344: Phoenix.View.render_to_iodata/3
       (phoenix) lib/phoenix/controller.ex:633: Phoenix.Controller.do_render/4
       (rumbl) web/controllers/video_controller.ex:1: Rumbl.VideoController.action/2
       (rumbl) web/controllers/video_controller.ex:1: Rumbl.VideoController.phoenix_controller_pipeline/2
       (rumbl) lib/phoenix/router.ex:261: Rumbl.Router.dispatch/2
       (rumbl) web/router.ex:1: Rumbl.Router.do_call/2
       (rumbl) lib/rumbl/endpoint.ex:1: Rumbl.Endpoint.phoenix_pipeline/1
       (rumbl) lib/phoenix/endpoint/render_errors.ex:34: Rumbl.Endpoint.call/2
       (phoenix) lib/phoenix/test/conn_test.ex:194: Phoenix.ConnTest.dispatch/5
       test/controllers/video_controller_test.exs:49

```
