# encoding: utf-8
# ##### BEGIN LICENSE BLOCK #####
# Ekylibre - Simple ERP
# Copyright (C) 2009 Brice Texier, Thibaud Merigon
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ##### END LICENSE BLOCK #####

# encoding: utf-8

module ApplicationHelper

  class Lister
    Item = Struct.new(:name, :args, :block)

    def initialize(type = :items)
      @items = []
      @type = type
      code  = "def #{@type.to_s}\n"
      code << "  @items\n"
      code << "end"
      eval(code)
    end

    def method_missing(method_name, *args, &block)
      @items << Item.new(method_name.to_sym, args, block)
      return nil
    end
  end

  def current_theme
    controller.current_theme
  end

  def current_user
    controller.current_user
  end

  # Helper which check authorization of an action
  def authorized?(url_options = {})
    self.controller.authorized?(url_options)
  end


  def selector_tag(name, choices = nil, options = {}, html_options = {})
    choices ||= :unroll
    choices = {:action => choices} if choices.is_a?(Symbol)
    return text_field_tag(name, nil, html_options.merge('data-selector' => url_for(choices)))
  end


  def selector(object_name, association, choices, options = {}, html_options = {})
    object = options[:object] || instance_variable_get("@#{object_name}")
    model = object.class
    unless reflection = object.class.reflections[association.to_sym]
      raise ArgumentError.new("Unknown reflection for #{model.name}: #{association.inspect}")
    end
    raise ArgumentError.new("Reflection #{reflection.name} must be a belongs_to") if reflection.macro != :belongs_to
    return text_field(object_name, reflection.foreign_key, html_options.merge('data-selector' => url_for(choices)))
  end

  # It's the menu generated for the current user
  # Therefore: No current user => No menu
  def menus
    Ekylibre.menu
  end

  # Return an array of menu and submenu concerned by the action (controller#action)
  def reverse_menus(action=nil)
    # action ||= "#{self.controller.controller_name}##{action_name}"
    # Ekylibre.reverse_menus[action]||[]
    return []
    Ekylibre.menu.stack(controller_name, action_name)
  end

  # LEGALS_ITEMS = [h("Ekylibre " + Ekylibre.version),  h("Ruby on Rails " + Rails.version),  h("Ruby "+ RUBY_VERSION.to_s)].join(" &ndash; ".html_safe).freeze

  def legals_sentence
    # "Ekylibre " << Ekylibre.version << " - Ruby on Rails " << Rails.version << " - Ruby #{RUBY_VERSION} - " << ActiveRecord::Base.connection.adapter_name << " - " << ActiveRecord::Migrator.current_version.to_s
    nbsp = "&nbsp;".html_safe # ,  h("Ruby on Rails") + nbsp + Rails.version, ("HTML" + nbsp + "5").html_sa, h("CSS 3")
    return [h("Ekylibre") + nbsp + Ekylibre.version].join(" &ndash; ").html_safe # ,  h("Ruby") + nbsp + RUBY_VERSION.to_s
  end

  def choices_yes_no
    [ [::I18n.translate('general.y'), true], [I18n.t('general.n'), false] ]
  end

  def radio_yes_no(name, value=nil)
    radio_button_tag(name, 1, value.to_s=="1", id => "#{name}_1") <<
      content_tag(:label, ::I18n.translate('general.y'), :for => "#{name}_1") <<
      radio_button_tag(name, 0, value.to_s=="0", id => "#{name}_0") <<
      content_tag(:label, ::I18n.translate('general.n'), :for => "#{name}_0")
  end

  def radio_check_box(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
    # raise Exception.new eval("@#{object_name}.#{method}").inspect
    radio_button_tag(object_name, method, TrueClass, :id => "#{object_name}_#{method}_#{checked_value}") << " " <<
      content_tag(:label, ::I18n.translate('general.y'), :for => "#{object_name}_#{method}_#{checked_value}") << " " <<
      radio_button_tag(object_name, method, FalseClass, :id => "#{object_name}_#{method}_#{unchecked_value}") << " " <<
      content_tag(:label, ::I18n.translate('general.n'), :for => "#{object_name}_#{method}_#{unchecked_value}")
  end

  def number_to_accountancy(value)
    number = value.to_f
    return (number.zero? ? '' : number.l)
  end

  def number_to_management(value)
    number = value.to_f
    return number.l
  end

  # def locale_selector
  #   # , :selected => ::I18n.locale)
  #   locales = ::I18n.active_locales.sort{|a,b| a.to_s <=> b.to_s}
  #   locale = nil # ::I18n.locale
  #   if params[:locale].to_s.match(/^[a-z][a-z][a-z]$/)
  #     locale = params[:locale].to_sym if locales.include? params[:locale].to_sym
  #   end
  #   locale ||= ::I18n.locale||::I18n.default_locale
  #   options = locales.collect do |l|
  #     content_tag(:option, ::I18n.translate("i18n.name", :locale => l), {:value => l, :dir => ::I18n.translate("i18n.dir", :locale => l)}.merge(locale == l ? {:selected => true} : {}))
  #   end.join.html_safe
  #   select_tag("locale", options, "data-redirect" => url_for())
  # end

  def locale_selector_tag
    # , :selected => ::I18n.locale)
    locales = ::I18n.active_locales.sort{|a,b| a.to_s <=> b.to_s}
    locale = nil # ::I18n.locale
    if params[:locale].to_s.match(/^[a-z][a-z][a-z]$/)
      locale = params[:locale].to_sym if locales.include? params[:locale].to_sym
    end
    locale ||= ::I18n.locale||::I18n.default_locale
    options = locales.collect do |l|
      content_tag(:option, ::I18n.translate("i18n.name", :locale => l), {:value => l, :dir => ::I18n.translate("i18n.dir", :locale => l), :selected => false, 'data-redirect' => url_for(:locale => l)}.merge(locale == l ? {:selected => true} : {}))
    end.join.html_safe
    select_tag("locale", options, "data-use-redirect" => "true")
  end


  def link_to_remove_nested_association(name, f)
    return link_to_remove_association(content_tag(:i) + h("labels.remove_#{name}".t), f, 'data-no-turbolink' => true, :class => "nested-remove remove-#{name}")
  end


  # Re-writing of link_to helper
  def link_to(*args, &block)
    if block_given?
      options      = args.first || {}
      html_options = args.second
      link_to(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2] || {}

      if options.is_a? Hash
        return (html_options[:remove] ? "" : "<a class='forbidden' disabled='true'>#{name}</a>".html_safe) unless authorized?(options)
      end

      html_options = convert_options_to_data_attributes(options, html_options)
      url = url_for(options)

      if html_options
        html_options = html_options.stringify_keys
        href = html_options['href']
        tag_options = tag_options(html_options)
      else
        tag_options = nil
      end

      href_attr = "href=\""+url+"\"" unless href
      "<a #{href_attr}#{tag_options}>".html_safe+(name || url)+"</a>".html_safe
    end
  end

  def li_link_to(*args)
    options      = args[1] || {}
    # if authorized?({:controller => controller_name, :action => action_name}.merge(options))
    if authorized?({:controller => controller_name, :action => :index}.merge(options))
      content_tag(:li, link_to(*args).html_safe)
    else
      ''
    end
  end

  def countries
    # [[]]+t('countries').to_a.sort{|a, b| a[1].ascii.to_s <=> b[1].ascii.to_s}.collect{|a| [a[1].to_s, a[0].to_s]}
    [[]] + Nomen::Countries.items.values.collect{|c| [c.human_name, c.name.to_s]}
  end

  def currencies
    # I18n.active_currencies.values.sort{|a, b| a.name.ascii.to_s <=> b.name.ascii.to_s}.collect{|c| [c.label, c.code]}
    [[]] + Nomen::Currencies.items.values.collect{|c| [c.human_name, c.name.to_s]}
  end

  def languages
    # I18n.valid_locales.collect{|l| [t("languages.#{l}"), l.to_s]}.to_a.sort{|a, b| a[0].ascii.to_s <=> b[0].ascii.to_s}
    [[]] + Nomen::Languages.items.values.collect{|l| [l.human_name, l.name.to_s]}
  end

  def back_url
    # if session[:history].is_a?(Array) and session[:history][0].is_a?(Hash)
    #   return session[:history][0][:url]
    # else
    return :back
    # end
  end

  def link_to_back(options={})
    link_to(tg(options[:label]||'back'), back_url)
  end

  #


  #
  def evalue(object, attribute, options={})
    label, value = attribute_item(object, attribute, options={})
    if options[:orient] == :vertical
      code  = content_tag(:tr, content_tag(:td, label.to_s, :class => :label))
      code << content_tag(:tr, content_tag(:td, value.to_s, :class => :value))
      return content_tag(:table, code, :class => "evalue verti")
    else
      code  = content_tag(:td, label.to_s, :class => :label)
      code << content_tag(:td, value.to_s, :class => :value)
      return content_tag(:table, content_tag(:tr, code), :class => "evalue hori")
    end
  end


  def attribute_item(object, attribute, options={})
    value_class = 'value'
    if object.is_a? String
      label = object
      value = attribute
      value = value.to_s unless [String, TrueClass, FalseClass].include? value.class
    else
      #     label = object.class.human_attribute_name(attribute.to_s)
      value = object.send(attribute)
      model = object.class
      model_name = model.name.underscore
      default = ["activerecord.attributes.#{model_name}.#{attribute.to_s}_id".to_sym]
      default << "activerecord.attributes.#{model_name}.#{attribute.to_s[0..-7]}".to_sym if attribute.to_s.match(/_label$/)
      default << "attributes.#{attribute.to_s}".to_sym
      default << "attributes.#{attribute.to_s}_id".to_sym
      label = ::I18n.translate("activerecord.attributes.#{model_name}.#{attribute.to_s}".to_sym, :default => default)
      if value.is_a? ActiveRecord::Base
        record = value
        value = record.send(options[:label]||[:label, :name, :code, :number, :inspect].detect{|x| record.respond_to?(x)})
        options[:url] = {:action => :show} if options[:url].is_a? TrueClass
        if options[:url].is_a? Hash
          options[:url][:id] ||= record.id
          # raise [model_name.pluralize, record, record.class.name.underscore.pluralize].inspect
          options[:url][:controller] ||= record.class.name.underscore.pluralize
        end
      else
        options[:url] = {:action => :show} if options[:url].is_a? TrueClass
        if options[:url].is_a? Hash
          options[:url][:controller] ||= object.class.name.underscore.pluralize
          options[:url][:id] ||= object.id
        end
      end
      value_class  <<  ' code' if attribute.to_s == "code"
    end
    if [TrueClass, FalseClass].include? value.class
      value = content_tag(:div, "", :class => "checkbox-#{value}")
    elsif value.respond_to?(:text)
      value = value.send(:text)
    elsif attribute.to_s.match(/(^|_)currency$/)
      value = value.to_currency.label
    elsif options[:currency] and value.is_a?(Numeric)
      value = ::I18n.localize(value, currency: (options[:currency].is_a?(TrueClass) ? object.send(:currency) : options[:currency].is_a?(Symbol) ? object.send(options[:currency]) : options[:currency]))
      value = link_to(value.to_s, options[:url]) if options[:url]
    elsif value.respond_to?(:strftime) or value.is_a?(Numeric)
      value = ::I18n.localize(value)
      value = link_to(value.to_s, options[:url]) if options[:url]
    elsif options[:duration]
      duration = value
      duration = duration*60 if options[:duration]==:minutes
      duration = duration*3600 if options[:duration]==:hours
      hours = (duration/3600).floor.to_i
      minutes = (duration/60-60*hours).floor.to_i
      seconds = (duration - 60*minutes - 3600*hours).round.to_i
      value = tg(:duration_in_hours_and_minutes, :hours => hours, :minutes => minutes, :seconds => seconds)
      value = link_to(value.to_s, options[:url]) if options[:url]
    elsif value.is_a? String
      classes = []
      classes << "code" if attribute.to_s == "code"
      classes << value.class.name.underscore
      value = link_to(value.to_s, options[:url]) if options[:url]
      value = content_tag(:div, value.html_safe, :class => classes.join(" "))
    end
    return label, value
  end


  def attributes_list(record = nil, options={}, &block)
    columns = options[:columns] || 3
    record ||= instance_variable_get("@#{controller_name.singularize}")
    attribute_list = AttributesList.new(record)
    raise ArgumentError.new("One parameter needed") unless block.arity == 1
    yield attribute_list if block_given?
    unless options[:without_custom_fields]
      unless attribute_list.items.detect{|item| item[0] == :custom_fields}
        attribute_list.custom_fields
      end
    end
    unless options[:without_stamp]
      attribute_list.attribute :creator, :label => :full_name
      attribute_list.attribute :created_at
      attribute_list.attribute :updater, :label => :full_name
      attribute_list.attribute :updated_at
      # attribute_list.attribute :lock_version
    end
    code = ""
    items = attribute_list.items.delete_if{|x| x[0] == :custom_fields}
    size = items.size
    if size > 0
      for item in items
        label, value = if item[0] == :custom
                         attribute_item(*item[1])
                       elsif item[0] == :attribute
                         attribute_item(record, *item[1])
                       end
        code << content_tag(:dl, content_tag(:dt, label) + content_tag(:dd, value))
      end
      code = content_tag(:div, code.html_safe, :class => "attributes-list")
    end
    return code.html_safe
  end

  class AttributesList
    attr_reader :items
    def initialize(object)
      @items = []
      @object = object
    end

    def attribute(*args)
      @items << [:attribute, args]
    end

    def custom(*args)
      @items << [:custom, args]
    end

    def custom_fields(*args)
      for custom_field in @object.custom_fields
        value = @object.custom_value(custom_field)
        unless value.blank?
          self.custom(custom_field.name, value)
        end
      end
      @items << [:custom_fields]
    end

  end


  def svg(options = {}, &block)
    return content_tag(:svg, capture(&block))
  end




  def dropdown_button(*args, &block)
    l = Lister.new(:links)
    yield l
    minimum = 0
    if args[1].nil?
      return nil unless l.links.size > 0
      minimum = 1
      args = l.links.first.args
    end
    args[2] ||= {}
    return content_tag(:div, :class => "btn-group btn-group-dropdown #{args[2][:class]}") do
      html = "".html_safe
      if l.links.size > minimum
        html << link_to(content_tag(:i), "#dropdown", :class => "btn btn-dropdown", 'data-toggle' => 'dropdown')
        html << content_tag(:ul, :class => "dropdown-menu") do
          l.links.collect do |link|
            content_tag(:li, send(link.name, *link.args, &link.block))
          end.join.html_safe
        end
      end
      html = tool_to(*args) + html
      html
    end
  end




  # 巣 Beehive permits to create modular interface organized in cells
  def beehive(name = nil, &block)
    html = ""
    return html unless block_given?
    name ||= "#{controller_name}_#{action_name}".to_sym
    board = Beehive.new(name, self)
    if block.arity < 1
      board.instance_eval(&block)
    else
      block[board]
    end
    return render(:partial => "backend/beehive", :object => board)
  end

  class Beehive
    attr_reader :name, :boxes, :template

    class TabBox < Array
      def self.short_name
        "tab"
      end
    end

    class HorizontalBox < Array
      def self.short_name
        "h"
      end
    end

    class Cell
      attr_reader :content, :name, :beehive, :options

      def initialize(name, beehive, options = {}, &block)
        @name = name
        @beehive = beehive
        @options = options
        if block_given?
          @content = @beehive.template.capture(&block)
          @has_content = true
        end
      end

      def content?
        !!@has_content
      end

      def title
        @options[:title] || (@name.is_a?(String) ? @name : ::I18n.t("labels.#{@name}", @options.merge(:default => @name.to_s.humanize)))
      end
    end

    def initialize(name, template)
      @name = name
      @boxes = []
      @current_box = nil
      @template = template
    end

    def cell(name = :details, options = {}, &block)
      c = Cell.new(name, self, options, &block)
      if @current_box
        @current_box << c
      else
        box = HorizontalBox.new
        box << c
        @boxes << box
      end
    end

    def hbox(&block)
      raise Exception.new("Cannot define box in other box") if @current_box
      @current_box = HorizontalBox.new
      block[self] if block_given?
      @boxes << @current_box unless @current_box.empty?
      @current_box = nil
    end

    def tabbox(&block)
      raise Exception.new("Cannot define box in other box") if @current_box
      @current_box = TabBox.new
      block[self] if block_given?
      @boxes << @current_box unless @current_box.empty?
      @current_box = nil
    end

  end






  def last_page(menu)
    # session[:last_page][menu.to_s]||
    url_for(controller: :dashboards, action: menu)
  end


  def doctype_tag
    return "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN\" \"http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd\">".html_safe
  end




  def search_results(search, options = {}, &block)
    return content_tag(:div, :class => :search) {
      # Show results
      html = "".html_safe
      html << content_tag(:ul, :class => :results) {
        counter = "a"
        search[:records].collect do |result|
          id = "result-" + counter
          counter.succ!
          content_tag(:li, :class => "result", :id => id) {
            (block.arity == 2 ? capture(result, id, &block) : capture(result, &block)).html_safe
          }
        end.join.html_safe
      } if search[:records]

      # Pagination
      html << content_tag(:span, :class => :pagination) {
        padding, gap = 9, 4
        page_min = params[:page].to_i - padding
        page_min = 1 if page_min < gap
        page_max = params[:page].to_i + padding
        page_max = search[:last_page] if page_max > search[:last_page]

        pagination = ""
        if page_min > 1
          pagination << link_to(content_tag(:i) + tl(:beginning), {:q => params[:q], :page => 1}, :class => :beginning)
          pagination << content_tag(:span, "&hellip;".html_safe) if page_min >= gap
        end
        for p in page_min..page_max
          attrs = {}
          attrs[:class] = "active" if p == params[:page]
          pagination << link_to("#{p}", {:q => params[:q], :page => p}, attrs)
        end
        pagination << content_tag(:span, "&hellip;".html_safe) if page_max < search[:last_page]
        pagination.html_safe
      } if search[:last_page] and search[:last_page] > 1

      # Return HTML
      html
    }
  end


  def icon_tags(options = {})
    # Favicon
    html  = tag(:link, :rel => "icon", :type => "image/png", :href => image_path("icon/favicon.png"), "data-turbolinks-track" => true)
    html << "\n".html_safe + tag(:link, :rel => "shortcut icon", :href => image_path("icon/favicon.ico"), "data-turbolinks-track" => true)
    # Apple touch icon
    unless options[:app].is_a?(FalseClass)
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon", :href => image_path("icon/iphone.png"), "data-turbolinks-track" => true) # , :sizes => "57x57"
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon", :sizes => "72x72", :href => image_path("icon/ipad.png"), "data-turbolinks-track" => true)
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon", :sizes => "114x114", :href => image_path("icon/iphone-retina.png"), "data-turbolinks-track" => true)
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon", :sizes => "144x144", :href => image_path("icon/ipad-retina.png"), "data-turbolinks-track" => true)
    end
    if options[:precomposed]
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon-precomposed", :href => image_path("icon/precomposed-iphone.png"), "data-turbolinks-track" => true) # , :sizes => "57x57"
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon-precomposed", :sizes => "72x72", :href => image_path("icon/precomposed-ipad.png"), "data-turbolinks-track" => true)
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon-precomposed", :sizes => "114x114", :href => image_path("icon/precomposed-iphone-retina.png"), "data-turbolinks-track" => true)
      html << "\n".html_safe + tag(:link, :rel => "apple-touch-icon-precomposed", :sizes => "144x144", :href => image_path("icon/precomposed-ipad-retina.png"), "data-turbolinks-track" => true)
    end
    return html
  end


  # Permits to use themes for Ekylibre
  #  stylesheet_link_tag 'application', 'list', 'list-colors'
  #  stylesheet_link_tag 'print', :media => 'print'
  def theme_link_tag()
    html = ""
    html << stylesheet_link_tag(theme_path("all.css"), :media => :all, "data-turbolinks-track" => true)
    return html.html_safe
  end

  def theme_button(name, theme='tekyla')
    image_path(theme_path("buttons/#{name}.png"))
  end

  def theme_path(name)
    "themes/#{current_theme}/#{name}"
  end


  # def resizable?
  #   return (session[:view_mode] == "resized" ? true : false)
  # end

  def viewport_tag
    tag(:meta, :name => "viewport", :content => "width=device-width, initial-scale=1.0, maximum-scale=1.0")
  end

  def title_tag
    r = [] # reverse_menus
    title = if current_user
              code = URI::parse(request.url).host # .split(".")[-3].to_s
              if r.empty?
                tc(:page_title_special, :company_code => code, :action => controller.human_action_name)
              else
                tc(:page_title, :company_code => code, :action => controller.human_action_name, :menu => tl("menus.#{r[0]}"))
              end
            else
              tc(:page_title_by_default, :action => controller.human_action_name)
            end
    return ("<title>" << h(title) << "</title>").html_safe
  end


  def heading_tag
    return content_tag(:h1, controller.human_action_name, :id => :title)
    # heading = "".html_safe
    # unless (rm = reverse_menus).empty?
    #   heading << link_to("labels.menus.#{rm[0]}".t, last_page(rm[0]), :class => :module)
    #   heading << content_tag(:span, "/", :class => "separator")
    # end
    # heading << content_tag(:span, controller.human_action_name, :class => :leaf)
    # content_tag(:h1, heading, :id => :title)
  end

  def subheading(i18n_key, options={})
    raise Exception.new("A subheading has already been given.") if content_for?(:subheading)
    if options[:here]
      return subheading_tag(tl(i18n_key, options))
    else
      content_for(:subheading, tl(i18n_key, options))
    end
  end

  def subheading_tag(title = nil)
    if content_for?(:subheading) or title
      return content_tag(:h2, title || content_for(:subheading), :id => :subtitle)
    end
    return nil
  end


  def notification_tag(mode)
    # content_tag(:div, flash[mode], :class => 'flash ' << mode.to_s) unless flash[mode].blank?
    code = ''
    if flash[:notifications].is_a?(Hash) and flash[:notifications][mode].is_a?(Array)
      for message in flash[:notifications][mode]
        message.force_encoding('UTF-8') if message.respond_to? :force_encoding
        code << "<div class='flash #{mode}' data-alert=\"true\"><div class='icon'></div><div class='message'><h3>#{tg('notifications.' << mode.to_s)}</h3><p>#{h(message).gsub(/\n/, '<br/>')}</p></div><a href=\"#\" class=\"close\">&times;</a></div>" # <div class='end'></div>
      end
    end
    code.html_safe
  end

  def notifications_tag
    return notification_tag(:error) <<
      notification_tag(:warning) <<
      notification_tag(:success) <<
      notification_tag(:information)
  end


  def table_of(array, html_options={}, &block)
    coln = html_options.delete(:columns)||3
    html, item, size = "", "", 0
    for item in array
      item << content_tag(:td, capture(item, &block))
      size += 1
      if size >= coln
        html << content_tag(:tr, item).html_safe
        item, size = "", 0
      end
    end
    html << content_tag(:tr, item).html_safe unless item.blank?
    return content_tag(:table, html, html_options).html_safe
  end





  # TOOLBAR

  def menu_to(name, url, options={})
    raise ArgumentError.new("##{__method__} cannot use blocks") if block_given?
    icon = (options.has_key?(:menu) ? options.delete(:menu) : url.is_a?(Hash) ? url[:action] : nil)
    sprite = options.delete(:sprite) || "icons-16"
    options[:class] = (options[:class].blank? ? 'mn' : options[:class]+' mn')
    options[:class] += ' '+icon.to_s if icon
    link_to(url, options) do
      (icon ? content_tag(:span, '', :class => "icon")+content_tag(:span, name, :class => "text") : content_tag(:span, name, :class => "text"))
    end
  end


  # def tool(code = nil, &block)
  #   raise ArgumentError.new("Arguments XOR block code are accepted, but not together.") if (code and block_given?) or (code.blank? and !block_given?)
  #   code = capture(&block) if block_given?
  #   content_for(:main_toolbar_default, code)
  #   return true
  # end

  def tool_to(name, url, options={})
    raise ArgumentError.new("##{__method__} cannot use blocks") if block_given?
    icon = (options.has_key?(:tool) ? options.delete(:tool) : url.is_a?(Hash) ? url[:action] : nil)
    options[:class] = (options[:class].blank? ? 'btn' : options[:class].to_s+' btn')
    options[:class] << ' btn-' + icon.to_s if icon
    link_to(url, options) do
      # (icon ? content_tag(:span, '', :class => "icon")+content_tag(:span, name, :class => "text") : content_tag(:span, name, :class => "text"))
      (icon ? content_tag(:i) + h(" ") + h(name) : h(name))
    end
  end



  def toolbar_tool_to(name, url, options={})
    return tool_to(name, url, options) if authorized?(url)
    return nil
  end


  def toolbar_export(nature, record = nil, options = {}, &block)
    exporter = Lister.new(:natures)
    yield exporter if block_given?
    if exporter.natures.size > 0

      for nature in exporter.natures
        key = nature.args.shift
        unless key.is_a?(String)
          raise ArgumentError.new("Expected String for document key: #{key.class.name}:#{key.inspect}")
        end
        add_deck(nature.name) do
          html = "".html_safe
          # if block_given?
          #   html = kujaku(&block)
          # end
          html << form_actions do
            DocumentTemplate.of_nature(nature.name.to_s).collect do |template|
              formats = template.formats
              dropdown_button(template.name, :format => formats.first, :template => template.id, :key => key) do |l|
                for format in formats
                  l.link_to("formats.#{format}".t, :format => format, :template => template.id, :key => key)
                end
              end
            end.join.html_safe
          end
          html << beehive do |b|
            b.tabbox do
              if document = Document.of(nature.name, key)
                b.cell :archives, :counter => document.archives_count do
                  # list(:archives, :controller => :documents, :id => document.id)
                  content_tag(:div, :class => :content) {
                    content_tag(:ul) {
                      document.archives.collect do |archive|
                        content_tag(:li, link_to(archive.archived_at.l, backend_document_archive_url(archive)) + " ".html_safe + archive.template_name)
                      end.join.html_safe
                    }
                  }
                end
              end
              # b.cell :upload do
              #   form_tag({:controller => :document_archives, :action => :create, :document_id => document.id}, {:multipart => true}) {
              #     file_field_tag(:file) + submit_tag
              #   }
              # end
            end
          end
          html
        end
      end

      default = exporter.natures.first
      return dropdown_button(content_tag(:i), '#' + default.name.to_s, :class => "btn btn-print", 'data-select-deck' => default.name) do |l|
        for nature in exporter.natures
          l.link_to(content_tag(:i) + h(nature.name.to_s.humanize), '#' + nature.name.to_s, 'data-select-deck' => nature.name)
        end if exporter.natures.size > 1
      end
    end
    return nil
  end

  def toolbar_mail_to(*args)
    args[2] ||= {}
    email_address = ERB::Util.html_escape(args[0])
    extras = %w{ cc bcc body subject }.map { |item|
      option = args[2].delete(item) || next
      "#{item}=#{Rack::Utils.escape(option).gsub("+", "%20")}"
    }.compact
    extras = extras.empty? ? '' : '?' + ERB::Util.html_escape(extras.join('&'))
    return tool_to(args[1], "mailto:#{email_address}#{extras}".html_safe, :tool => :mail)
  end

  def toolbar_missing(action, *args)
    options = (args[-1].is_a?(Hash) ? args.delete_at(-1) : {})
    record = args.shift
    url = {}
    url.update(options.delete(:params)) if options[:params].is_a? Hash
    url[:controller] ||= controller_name
    url[:action] ||= action
    url[:id] = record.id if record and record.class < ActiveRecord::Base
    variants = options.delete(:variants)
    variants ||= {"actions.#{url[:controller]}.#{action}".to_sym.t({:default => "labels.#{action}".to_sym}.merge((record and record.class < ActiveRecord::Base) ? record.attributes.symbolize_keys : {})) => url} if authorized?(url)
    return dropdown_button do |l|
      for name, url_options in variants
        variant_url = url.merge(url_options)
        l.link_to(name, variant_url, options) if authorized?(variant_url)
      end
    end
    # return tool_to(t("actions.#{url[:controller]}.#{action}".to_sym, {:default => "labels.#{action}".to_sym}.merge(record ? record.attributes.symbolize_keys : {})), url, tag_options) if authorized?(url)
    # return nil
  end


  # Build the main toolbar
  def main_toolbar_tag
    content_tag(:div, content_for(:main_toolbar), :class => "main-toolbar")
  end

  # Create the main toolbar with the same API as toolbar
  def main_toolbar(options = {}, &block)
    content_for(:main_toolbar, toolbar(options.merge(:wrap => false), &block))
    return nil
  end

  # Build a tool bar composed of tool groups composed of tool
  def toolbar(options={}, &block)
    html = '[EmptyToolbarError]'
    toolbar = Toolbar.new
    yield toolbar if block_given?

    # To HTML
    html = ''.html_safe
    for group, tools in toolbar.tools
      tools_html = tools.collect{|t| (t[:block] ? send("toolbar_#{t[:type]}", *t[:args], &t[:block]) : send("toolbar_#{t[:type]}", *t[:args])) }.compact.join.html_safe
      unless tools_html.blank?
        html << content_tag(:div, tools_html.html_safe, :class => "btn-group btn-group-#{group}")
      end
    end

    unless options[:wrap].is_a?(FalseClass)
      html = content_tag(:div, html, :class => 'toolbar' << (options[:class] ? ' ' << options[:class].to_s : ''))
    end
    return html
  end

  # This class permit to register the composition of a toolbar
  class Toolbar
    attr_reader :tools

    def initialize()
      @tools = {}
      @group = "0"
    end

    # def link(*args)
    #   add(:link, *args)
    # end

    def tool_to(*args)
      add(:tool_to, *args)
    end

    def mail_to(*args)
      add(:mail_to, *args)
    end

    def export(*args, &block)
      args << {} unless args[-1].is_a?(Hash)
      args[-1][:group] ||= new_group
      @export = true
      add(:export, *args, &block)
    end

    def method_missing(method_name, *args, &block)
      raise ArgumentError.new("Block can not be accepted") if block_given?
      args << {} unless args[-1].is_a?(Hash)
      args[-1][:group] ||= new_group if args[-1][:variants]
      add(:missing, method_name.to_s.gsub(/\_+$/, '').to_sym, *args)
    end

    private

    def add(type, *args, &block)
      options = args[-1].is_a?(Hash) ? args[-1] : {}
      group = (options.delete(:group) || "default").to_sym
      button = {:type => type, :args => args}
      button[:block] = block if block_given?
      @tools[group] ||= []
      @tools[group] << button
    end

    # Build an return a new group name
    def new_group
      @group.succ!
      "g#{@group}".to_sym
    end

  end


  def error_messages(object)
    object = instance_variable_get("@#{object}") unless object.respond_to?(:errors)
    return unless object.respond_to?(:errors)
    unless (count = object.errors.size).zero?
      I18n.with_options :scope => [:errors, :template] do |locale|
        header_message = locale.t :header, :count => count, :model => object.class.model_name.human
        introduction = locale.t(:body)
        messages = object.errors.full_messages.map do |msg|
          content_tag(:li, msg)
        end.join.html_safe
        message = ""
        message << content_tag(:h3, header_message) unless header_message.blank?
        message << content_tag(:p, introduction) unless introduction.blank?
        message << content_tag(:ul, messages)

        html = ''
        html << content_tag(:div, "", :class => :icon)
        html << content_tag(:div, message.html_safe, :class => :message)
        html << content_tag(:div, "", :class => :end)
        return content_tag(:div, html.html_safe, :class => "flash error")
      end
    else
      ''
    end
  end

  def form_actions(&block)
    return content_tag(:div, capture(&block), :class => "form-actions")
  end

  def form_fields(&block)
    return content_tag(:div, capture(&block), :class => "form-fields")
  end

  def backend_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: Backend::FormBuilder)), &block)
  end

  def backend_fields_for(object, *args, &block)
    options = args.extract_options!
    simple_fields_for(object, *(args << options.merge(builder: Backend::FormBuilder)), &block)
  end


  # Wraps a label and its input in a standard wrapper
  def field(label, input, options = {}, &block)
    return content_tag(:div,
                       content_tag(:label, label, :class => "control-label") +
                       content_tag(:div, (block_given? ? capture(&block) : input), :class => "controls"),
                       :class => "control-group")
  end


  def field_set(*args, &block)
    options = (args[-1].is_a?(Hash) ? args.delete_at(-1) : {})
    name = args.delete_at(0) || "general-informations".to_sym
    return content_tag(:div,
                       content_tag(:div,
                                   content_tag(:span, "", :class => :icon) +
                                   content_tag(:span, (name.is_a?(Symbol) ? name.to_s.gsub('-', '_').t(:default => ["labels.#{name.to_s.gsub('-', '_')}".to_sym, "form.legends.#{name.to_s.gsub('-', '_')}".to_sym, name.to_s.humanize]) : name.to_s)) +
                                   content_tag(:span, "", :class => :toggle),
                                   :class => "fieldset-legend " + (options[:collapsed] ? 'collapsed' : 'not-collapsed'), 'data-toggle-set' => ".fieldset-fields") +
                       content_tag(:div, capture(&block), :class => "fieldset-fields"), :class => "fieldset", :id => name) # "#{name}-fieldset"
  end


  def steps_tag(record, steps, options={})
    name = options[:name] || record.class.name.underscore
    state_method = options[:state_method] || :state
    state = record.send(state_method).to_s
    code = ''
    for step in steps
      title = tc("#{name}_steps.#{step[:name]}")
      classes  = "step"
      classes << " active" if step[:actions].detect{ |url| not url.detect{|k, v| params[k].to_s != v.to_s}} # url = {:action => url.to_s} unless url.is_a? Hash
      classes << " disabled" unless step[:states].include?(state)
      title = link_to(title, (record.id ? step[:actions][0].merge(:id => record.id) : "#"))
      code << content_tag(:div, '&nbsp;'.html_safe, :class => 'transition') unless code.blank?
      code << content_tag(:div, title, :class => classes)
    end
    return content_tag(:div, code.html_safe, :class => "stepper stepper-#{steps.count}-steps")
  end



  def product_stocks_options(product)
    options = []
    options += product.stocks.collect{|x| [x.label, x.id]}
    options += Building.of_product(product).collect{|x| [x.name, -x.id]}
    return options
  end


  # Imported from app/helpers/relations_helper.rb
  def condition_label(condition)
    if condition.match(/^generic/)
      klass, attribute = condition.split(/\-/)[1].pluralize.classify.constantize, condition.split(/\-/)[2]
      return tl("conditions.filter_on_attribute_of_class", :attribute => klass.human_attribute_name(attribute), :class => klass.model_name.human)
    else
      return tl("conditions.#{condition}")
    end
  end



end

