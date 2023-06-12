module RelatedFieldsHelper
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to(name, '#', onclick: "remove_fields(this);return false;", class: 'btn btn-white btn-xs')
  end

  def link_to_add_fields(name, f, association)
    fields = get_fields(f, association)

    link_to(name, '#', onclick: "add_fields(this, '#{association}', '#{escape_javascript(fields)}');return false;", class: 'btn btn-success btn-xs')
  end

  def link_to_add_fields_custom(name, f, association, classes)
    fields = get_fields(f, association)

    link_to(name, '#', onclick: "add_fields(this, '#{association}', '#{escape_javascript(fields)}');return false;", class: classes)
  end

  private

  def get_fields(f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
      render("#{association.to_s.singularize}_fields", f: builder)
    end
  end
end
