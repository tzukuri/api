ActiveAdmin.register BetaUser do
    menu parent: 'Beta'

    permit_params :email, :name, :invite_token, :score, :selected, :birth_date, :city

    index do
      selectable_column
      id_column
      column :email
      column :name
      column :invite_token
      column :score
      column :selected
      column :birth_date
      column :city
    end

    filter :email
    filter :name
    filter :score
    filter :selected
    filter :city


end
