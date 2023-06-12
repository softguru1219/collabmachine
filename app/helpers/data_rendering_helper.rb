module DataRenderingHelper
  # this is the framework-blessed way to render ruby data as javascript
  # https://apidock.com/rails/v6.0.0/ERB/Util/json_escape
  def js_object(data)
    raw json_escape(data.to_json)
  end
end
