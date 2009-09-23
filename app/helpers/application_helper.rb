# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Returns the css class +active+ if the current controller is among
  # the names in the arguments.
  #
  # Used in navigation menus to get an indicator of the currently active page.
  def active_by_controller(*names)
    " active " if names.include?(params[:controller])
  end

  # Returns the css class +active+ if the current action is an action in the given
  # controller and is among the names in the arguments.
  #
  # Used in navigation menus to get an indicator of the currently active page.
  def active_by_action(controller, *names)
    " active " if params[:controller] == controller && names.include?(params[:action])
  end

  # Returns a disable HTML attribute if the argument is +false+.
  def disabled_if(c)
    ' disabled="disabled" ' if c
  end

  # Convenience method to see if a string is really empty (= not nil, empty,
  # or filled with whitespace).
  def empty?(a)
    a.nil? || a.strip.empty?
  end

  # Creates a fully qualified URL if the given +url+ is not qualified.
  def qualified_url(url)
    unless url =~ /^http:\/\//i
      url = "http://" + url
    end

    url
  end

  # Turns a text into HTML paragraphs. Paragraphs should be separated
  # by empty lines.
  def paragraphize(text, tag_attrs = '', escape = true)
    text = h(text) if escape
    "<p #{tag_attrs}>" + text.gsub(/^\s*$/, "</p><p #{tag_attrs}>") + "</p>"
  end
  # Inserts HTML breaks at line breaks.
  def linebreakize(text, escape = true)
    text = h(text) if escape
    text.split($/).join("<br/>")
  end

  # Creates a link for sorting a table based on a column.
  #
  # [+title+] The link's text
  # [+column+] The sort column
  #
  # Options:
  #
  # [+:unless+] A condition for link_to_unless
  def sort_link(title, column, options = {})
    condition = options[:unless] if options.has_key?(:unless)
    sort_dir = params[:d] == 'up' && params[:c] == column ? 'down' : 'up'
    link_to_unless condition, title,
      :overwrite_params => { :c => column, :d => sort_dir }
  end

  # Generates an image tag for uploaded images
  #
  # [+image+] The image model
  # [+thumb+] Indicates if the image tag should show the thumbnail or not
  def uploaded_image_tag(image, thumb = false)
    options = { :alt => image.name }

    image_path = "/images/"

    if ActionController::Base.relative_url_root
      image_path = ActionController::Base.relative_url_root + image_path
    end

    if thumb
      options[:width] = image.thumb_width
      options[:height] = image.thumb_height
      options[:src] = image_path + image.thumb_url
    else
      options[:width] = image.width
      options[:height] = image.height
      options[:src] = image_path + image.image_url
    end

    return tag("img", options)
  end
end
