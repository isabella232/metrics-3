Rails.application.routes.draw do
  resources :metrics do
    get "preview", on: :collection
    get "graph", on: :member
  end

  post "slack" => "slack#slash_command", defaults: { format: :text }

  root to: redirect("metrics", status: 302)
end
