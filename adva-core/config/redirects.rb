Adva::Registry.set :redirect, {
  'admin/sites#update'    => lambda { |responder| responder.resources.unshift(:edit) },

  'admin/pages#update'    => lambda { |responder| responder.resources },
  'admin/pages#destroy'   => lambda { |responder| [*(responder.resources[0..-2] << :sections)] },

  'installations#create'  => lambda { |responder| '/' },
  'articles#show'         => lambda { |responder| responder.resource.section }
}